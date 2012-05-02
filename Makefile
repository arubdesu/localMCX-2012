include /usr/local/share/luggage/luggage.make
TITLE=LocalMCXstarter
REVERSE_DOMAIN=com.afp548.LocalMCX-starter.pkg
PAYLOAD=pack-usr-local-sbin-networkCheckers.py \
pack-Library-LaunchDaemons-com.afp548.localMCX-fixMACaddy.plist \
pack-Library-LaunchDaemons-com.afp548.LocalMCX-fixSearchPath.plist \
pack-Library-LaunchAgents-com.afp548.networkingUp.plist \
pack-usr-local-sbin-fixComputerRecord.sh \
pack-usr-local-sbin-LocalMCX-fixSearchPath.sh \
pack-var-db-dslocal-nodes-MCX \
pack-var-db-dslocal-nodes-MCX-computers-plists \
pack-var-db-dslocal-nodes-MCX-computergroups-plists \
pack-var-db-dslocal-nodes-MCX-users \
pack-var-db-dslocal-nodes-MCX-groups

modify_packageroot:
	@sudo chgrp wheel ${WORK_D}/Library
	@sudo chmod 755 ${WORK_D}/Library

prep-var-db-dslocal: l_var_db
	@sudo mkdir ${WORK_D}/var/db/dslocal
	@sudo chown root:wheel ${WORK_D}/var/db/dslocal
	@sudo chmod 755 ${WORK_D}/var/db/dslocal

prep-var-db-dslocal-nodes: prep-var-db-dslocal
	@sudo mkdir ${WORK_D}/var/db/dslocal/nodes
	@sudo chown root:wheel ${WORK_D}/var/db/dslocal
	@sudo chmod 755 ${WORK_D}/var/db/dslocal/nodes

prep-var-db-dslocal-nodes-MCX: prep-var-db-dslocal-nodes
	@sudo mkdir ${WORK_D}/var/db/dslocal/nodes/MCX
	@sudo chown root:wheel ${WORK_D}/var/db/dslocal/nodes/MCX
	@sudo chmod 600 ${WORK_D}/var/db/dslocal/nodes/MCX
	@echo "Creating \"var/db/dslocal/nodes/MCX\" directory"

pack-var-db-dslocal-nodes-MCX: prep-var-db-dslocal-nodes-MCX MCX/
	@sudo ${DITTO} MCX/ ${WORK_D}/var/db/dslocal/nodes/MCX/

prep-var-db-dslocal-nodes-MCX-users:
	@sudo mkdir -p ${WORK_D}/var/db/dslocal/nodes/MCX/users
	@sudo chown root:wheel ${WORK_D}/var/db/dslocal/nodes/MCX/users
	@sudo chmod 700 ${WORK_D}/var/db/dslocal/nodes/MCX/users

prep-var-db-dslocal-nodes-MCX-groups:
	@sudo mkdir -p ${WORK_D}/var/db/dslocal/nodes/MCX/groups
	@sudo chown root:wheel ${WORK_D}/var/db/dslocal/nodes/MCX/groups
	@sudo chmod 700 ${WORK_D}/var/db/dslocal/nodes/MCX/groups

prep-var-db-dslocal-nodes-MCX-computers:
	@sudo mkdir -p ${WORK_D}/var/db/dslocal/nodes/MCX/computers

prep-var-db-dslocal-nodes-MCX-computergroups:
	@sudo mkdir -p ${WORK_D}/var/db/dslocal/nodes/MCX/computergroups

pack-var-db-dslocal-nodes-MCX-users: prep-var-db-dslocal-nodes-MCX-users users/
	@sudo ${DITTO} users/ ${WORK_D}/var/db/dslocal/nodes/MCX/

pack-var-db-dslocal-nodes-MCX-groups: prep-var-db-dslocal-nodes-MCX-groups groups/
	@sudo ${DITTO} groups/ ${WORK_D}/var/db/dslocal/nodes/MCX/

pack-var-db-dslocal-nodes-MCX-computers-plists: prep-var-db-dslocal-nodes-MCX-computers computers/
	@sudo ${DITTO} computers/ ${WORK_D}/var/db/dslocal/nodes/MCX/computers/
	@sudo chown -R root:wheel ${WORK_D}/var/db/dslocal/nodes/MCX/computers
	@sudo chmod -R 600 ${WORK_D}/var/db/dslocal/nodes/MCX/computers
	@sudo chown root:wheel ${WORK_D}/var/db/dslocal/nodes/MCX/computers
	@sudo chmod 700 ${WORK_D}/var/db/dslocal/nodes/MCX/computers

pack-var-db-dslocal-nodes-MCX-computergroups-plists: prep-var-db-dslocal-nodes-MCX-computergroups computergroups/
	@sudo ${DITTO} computergroups/ ${WORK_D}/var/db/dslocal/nodes/MCX/computergroups/
	@sudo chown -R root:wheel ${WORK_D}/var/db/dslocal/nodes/MCX/computergroups
	@sudo chmod -R 600 ${WORK_D}/var/db/dslocal/nodes/MCX/computergroups
	@sudo chown root:wheel ${WORK_D}/var/db/dslocal/nodes/MCX/computergroups
	@sudo chmod 700 ${WORK_D}/var/db/dslocal/nodes/MCX/computergroups