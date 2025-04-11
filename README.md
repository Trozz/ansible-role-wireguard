# Ansible WireGuard Role

This role automates the installation and configuration of WireGuard on Debian/Ubuntu systems. It generates private and public keys, sets up the WireGuard interface, and optionally restarts the system or the WireGuard service.

## Requirements

- Ansible ≥ 2.15
- Access to a Debian/Ubuntu host (or container) where WireGuard can be installed
- `community.general` collection (for `modprobe` tasks)

## Role Variables

Some commonly used variables:
- **listen_port** (default: `32091`) – Port to listen on for WireGuard connections  
- **mtu** (default: `1420`) – MTU for the WireGuard interface  
- **ip_cidr_range** (default: `16`) – CIDR range used by WireGuard  
- **interface_name** (default: `wg0`) – Name of the WireGuard interface  
- **inte_ip** – Address assigned to the WireGuard interface (must be specified when running)

All defaults are in [defaults/main.yml](defaults/main.yml).

## Usage

Include this role in your playbook:

```yaml
- hosts: all
  become: yes
  vars:
    inte_ip: 10.255.255.1
  roles:
    - role: ansible-wireguard
```

When the role runs, it will:
1. Install WireGuard and related packages.
2. Set up keys if not already present.
3. Configure the interface.
4. Optionally add peer details to the generated config.

## Testing

A basic test inventory and playbook are in [tests/](tests/). Run them with Docker (using a container image that supports WireGuard):

```sh
cd tests
./run.sh <ansible_docker_tag>
```

## License

[MIT License](LICENSE)

## Authors / Maintainers

- @Trozz ([Michael Leer](mailto:michael@leer.dev))
