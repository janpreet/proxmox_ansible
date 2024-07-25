package proxmox

import future.keywords.in
import future.keywords.if

allowed_hosts := {"proxmox"}

allowed_tasks := {
    "set_fact",
    "stat",
    "debug",
    "command",
    "shell",
    "wait_for",
    "ping"
}

deny[msg] {
    some play in input.plays
    not play.hosts in allowed_hosts
    msg := sprintf("Invalid host: %v. Allowed hosts are %v", [play.hosts, allowed_hosts])
}

deny[msg] {
    some play in input.plays
    some task in play.tasks
    not task.name in allowed_tasks
    msg := sprintf("Task '%v' uses disallowed module. Allowed modules are %v", [task.name, allowed_tasks])
}

deny[msg] {
    some play in input.plays
    not play.become == true
    msg := "All plays must have 'become: yes' set"
}

deny[msg] {
    some play in input.plays
    some task in play.tasks
    startswith(task.command, "pvecm")
    not is_first_node_condition(task.when)
    not is_not_first_node_condition(task.when)
    msg := "pvecm commands should only be used on the first node or when joining the cluster"
}

is_first_node_condition(when) {
    is_string(when)
    contains(when, "is_first_node")
}

is_first_node_condition(when) {
    is_array(when)
    some condition in when
    contains(condition, "is_first_node")
}

is_not_first_node_condition(when) {
    is_string(when)
    contains(when, "not is_first_node")
}

is_not_first_node_condition(when) {
    is_array(when)
    some condition in when
    contains(condition, "not is_first_node")
}

deny[msg] {
    some play in input.plays
    some task in play.tasks
    task.wait_for.timeout > 600
    msg := "wait_for task timeout should not exceed 600 seconds"
}

allow_add_node {
    some play in input.plays
    some task in play.tasks
    task.name == "Ensure first_node_ip is accessible from this node"
    startswith(task.shell, "ping")
}

deny[msg] {
    some play in input.plays
    some task in play.tasks
    task.name == "Add this node to the cluster"
    not allow_add_node
    msg := "Must ping first node before adding this node to the cluster"
}

deny[msg] {
    some play in input.plays
    some task in play.tasks
    task.name == "Setup QDevice for two-node cluster"
    not contains(task.when, "is_two_node_cluster")
    msg := "QDevice setup should only be performed for two-node clusters"
}

allow := msg {
    count(deny) == 0
    msg := "Playbook is allowed. No policy violations detected."
}