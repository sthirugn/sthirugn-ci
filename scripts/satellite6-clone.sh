# git clone the project
git clone "$SATELLITE_CLONE_REPO" -b "$SATELLITE_CLONE_BRANCH" --single-branch
cd satellite-clone

# Find the major version and run the control_node_setup script
major=cat /etc/redhat-release | cut -f1 -d. | awk '{print $7}'
sed -i "s/^export RHEL_MAJOR_VERSION.*/export RHEL_MAJOR_VERSION=$major/" helpers/control_node_setup.sh
chmod 755 helpers/control_node_setup.sh
/bin/bash helpers/control_node_setup.sh

# Run partition reallocation script
chmod 755 helpers/reallocate.sh
/bin/bash helpers/reallocate.sh

# Copy inventory file and update its parameters
cp inventory.sample inventory
sed -i "s/^192.168.1.100/$IP_ADDRESS/" inventory

# Copy vars file and update its parameters
cp satellite-clone-vars.sample.yml satellite-clone-vars.yml
sed -i "s/^satellite_version.*/satellite_version:$SATELLITE_VERSION/" satellite-clone-vars.yml
sed -i "s/^activationkey.*/activationkey:$ACTIVATION_KEY/" satellite-clone-vars.yml
sed -i "s/^org.*/org:$ORGANIZATION/" satellite-clone-vars.yml
sed -i "s/^backup_dir.*/backup_dir:$BACKUP_DIR/" satellite-clone-vars.yml
sed -i "s/^include_pulp_data.*/include_pulp_data:$INCLUDE_PULP_DATA/" satellite-clone-vars.yml
sed -i "s/^required_root_free_space.*/required_root_free_space:$REQUIRED_ROOT_FREE_SPACE/" satellite-clone-vars.yml
sed -i "s/^disable_firewall.*/disable_firewall:$DISABLE_FIREWALL/" satellite-clone-vars.yml
sed -i "s/^run_katello_reindex.*/run_katello_reindex:$RUN_KATELLO_INDEX/" satellite-clone-vars.yml
sed -i "s/^run_pre_install_check.*/run_pre_install_check:$RUN_PRE_INSTALL_CHECK/" satellite-clone-vars.yml
sed -i "s/^register_to_portal.*/register_to_portal:$REGISTER_TO_PORTAL/" satellite-clone-vars.yml
sed -i "s/^rhel_migration.*/rhel_migration:$RHEL_MIGRATION/" satellite-clone-vars.yml

ansible-playbook -i inventory satellite-clone-playbook.yml
