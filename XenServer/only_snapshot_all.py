#!/usr/bin/python
# Script to create snapshot of all VMs XenServer at once.
# Snapshots are converted to. XVA and saved in / mnt / backup.
# Ricardo Martins - http://www.ricardomartins.com.br

import commands, time

def get_backup_vms():
   result = []

   cmd = "xe vm-list is-control-domain=false is-a-snapshot=false"
   output = commands.getoutput(cmd)

   for vm in output.split("\n\n\n"):
      lines = vm.splitlines()
      uuid = lines[0].split(":")[1][1:]
      name = lines[1].split(":")[1][1:]
      result += [(uuid, name)]

   return result

def backup_vm(uuid, filename, timestamp):
   cmd = "xe vm-snapshot uuid=" + uuid + " new-name-label=" + timestamp
   snapshot_uuid = commands.getoutput(cmd)

   cmd = "xe template-param-set is-a-template=false ha-always-run=false uuid=" + snapshot_uuid
   commands.getoutput(cmd)

   cmd = "xe vm-export vm=" + snapshot_uuid + " filename=" + filename
   commands.getoutput(cmd)

   cmd = "xe vm-uninstall uuid=" + snapshot_uuid + " force=true"
   commands.getoutput(cmd)

for (uuid, name) in get_backup_vms():
   timestamp = time.strftime("%Y%m%d-%H%M", time.localtime())
   print timestamp, uuid, name
   filename = "'/mnt/backup/'\"" + timestamp + "_" + name + ".xva\""
   backup_vm(uuid, filename, timestamp)
