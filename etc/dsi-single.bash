#!/bin/bash

function bring-up-cluster() {
    pushd .
    rm -rf ./dsi
          set -e 
          set -v
          git clone https://github.com/rzh/dsi
          cd dsi
          # install terraform
          mkdir keys
          mkdir terraform
          cd terraform
          wget https://github.com/rzh/dsi/releases/download/t0.5.3/terraform_0.5.3_linux_amd64.zip -O temp.zip
          unzip temp.zip
          rm temp.zip
          # install workload wrapper
          cd ../bin
          wget --no-check-certificate  https://github.com/rzh/mc/releases/download/r0.0.1/mc.tar.gz -O - | tar zxv

    cd ../..
    # - commddand: shell.exec
    # bring up the cluster
        pwd 
        cd dsi
          set -e 
          set -o verbose
          # to create single mongod EC2 cluster
          cd ./clusters/single
          cp ../../terraform/* .
          # stage aws credential for terraform
          ../../bin/make_terraform_env.sh ${terraform_key} ${terraform_secret} https://s3.amazonaws.com/mciupload/dsi/${build_variant}/${revision}/mongod-${build_id}
          # generate aws private key file
          echo "${ec2_pem}" > ../../keys/aws.pem
          chmod 400 ../../keys/aws.pem
          # create all resources and instances
          ./terraform apply
          # this will extract all public and private IP address information
          ./env.sh
          echo "EC2 Cluster STARTED."

popd
}

function configure-mongodb-single-member-replica-cluster() {
    pushd .
    cd dsi
          set -e 
          set -o verbose
          cd ./clusters/single
          # configure mongodb cluster with wiredTiger
          ../../bin/config-single-replica.sh mongodb wiredTiger
          echo "Single MongoDB Replica Cluster STARTED."

    popd
}

function configure-standalone-mongodb() {
    pushd .
    cd dsi
          set -e 
          set -o verbose
          cd ./clusters/single
          # configure mongodb cluster with wiredTiger
          ../../bin/config-standalone.sh mongodb wiredTiger
          echo "Standalone MongoDB STARTED."

    popd
}

function run-ycsb-tests() {
    pushd .
    cd dsi
    setup=$1; shift

          set -e
          set -v
          cd ./clusters/single
          # run ycsb test
          ./bin/mc -config single-ycsb.json -run ycsb-run-${setup} -o perf.json 

    popd
}

function run-hammer-tests() {
    pushd .
    cd dsi
    setup=$1; shift

          set -e
          set -v
          cd ./clusters/single
          # run hammer test
          ./bin/mc -config single-hammer.json -run hammer-run-${setup} -o perf.json 

    popd
}

function destroy-cluster() {
    pushd .
    cd ./dsi
    cd ./clusters/single
          set -e 
          set -o verbose
          # configure mongodb cluster with wiredTiger
          yes yes | ./terraform destroy
          echo "Cluster DESTROYED."

    popd
}

function test-standalone() {
    pushd .

echo "test standalone "

  # - name: bringup_cluster
  bring-up-cluster
  # - name: config_standalone
  configure-mongodb-single-member-replica-cluster
  # - name: run_ycsb
  # - name: config_standalone
  # - name: run_hammer

  popd
}

function test-replica() {
    pushd .
echo "test replica"
  # - name: config_single_member_replica
  # - name: run_ycsb
  # - name: config_single_member_replica
  # - name: run_hammer
  # - name: destroy_cluster
destroy-cluster
popd
}

source ./security.bash

test-standalone
test-replica

