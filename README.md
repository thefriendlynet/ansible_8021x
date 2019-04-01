# Ansible Playbooks for automating your 802.1x projects

## Adding vlan groups to (Cisco) switches
Scan your switches for VLAN names matching a regular expression, then add
the corresponding VLAN ID's for matching VLAN's with configured ports to a
VLAN group.
The RADIUS server (e.g. Cisco ISE) will now be able to push a name to the
switch. The switch decides which ID('s) will be used on the interface.


## How to use the vlan_group playbook
- Compliance check or dry-run, discover which switches need changes
    vlan group named _vlan_group_name_ should contain a list of IDs for VLANs
    actually configured on interfaces whose name matches regular expression
    _search_vlan_pattern_ :
    case insensitive names optionally starting with
    one or two letters, followed by one or more digits, followed by zero or more
    letters, a dash, the string 'voip', again a dash and one or more digits.
    (i.e. b22a-voip-555 or 22-VoIP-555 or b22-VOIP-555)
    ```bash
    ansible-playbook vlan_group.yaml --check -v \
      -e "search_vlan_pattern='(?i)^([a-z]{1,2})?\d+\w*-voip-\d+'" \
      -e "vlan_group_name='DATA'"
    ```

- After possibly having filtered out only the switches that need changes, and
    having added these to the inventory as a new group, apply changes to switches
    in the inventory group _change_these_ :
    ```bash
    ansible-playbook vlan_group.yaml -e "which_hosts='change_these'" \
      -e "search_vlan_pattern='(?i)^([a-z]{1,2})?\d+\w*-voip-\d+'" \
      -e "vlan_group_name='DATA'"
    ```
    If the list of switches to fix is small, it's fine to use `--limit` of course.

- If you don't want to match a VLAN name, but want to configure a vlan group
    with a fixed VLAN ID everywhere, and if you don't care if switches might not
    (yet) have ports in said VLAN :
    ```bash
    ansible-playbook vlan_group.yaml \
      -e "force_vlan_id=705" \
      -e "vlan_group_name='VG_705'" \
      -e "only_vlans_with_configured_ports=false"
    ```


## Bonus round
As an added bonus we've added a bash script to clean up the vlan_group Ansible playbook output.
The script assumes you're using the yaml stdout callback. Either specify this in your `ansible.cfg` :
```bash
[defaults]
stdout_callback = yaml
bin_ansible_callbacks = True
```
or use the environment variables:
```bash
export ANSIBLE_STDOUT_CALLBACK=yaml
export ANSIBLE_BIN_ANSIBLE_CALLBACKS=1
```

If you `| tee vlan_group_check.log` your ansible-playbook output or use
`ANSIBLE_LOG_PATH`, you can use the script to show the relevant
portions of the output.
