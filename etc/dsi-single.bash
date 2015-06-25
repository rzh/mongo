#!/bin/bash

function bring-up-cluster() {
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

    cd ..
    # - commddand: shell.exec
    # bring up the cluster
        cd dsi
          set -e 
          set -o verbose
          # to create single mongod EC2 cluster
          cd ./clusters/single
          cp ../../terraform/* .
          # stage aws credential for terraform
          ../../bin/make_terraform_env.sh ${terraform_key} ${terraform_secret} https://s3.amazonaws.com/mciupload/dsi/${build_variant}/${revision}/mongod-${build_id}
          # generate aws private key file
          echo ${ec2_pem} > ../../keys/aws.pem
          # create all resources and instances
          ./terraform apply
          # this will extract all public and private IP address information
          ./env.sh
          echo "EC2 Cluster STARTED."

    cd ..
}

function configure-mongodb-single-member-replica-cluster() {
        cd dsi
          set -e 
          set -o verbose
          cd ./clusters/single
          # configure mongodb cluster with wiredTiger
          ../../bin/config-single-replica.sh mongodb wiredTiger
          echo "Single MongoDB Replica Cluster STARTED."

        cd  ..
}

function configure-standalone-mongodb() {
        cd dsi
          set -e 
          set -o verbose
          cd ./clusters/single
          # configure mongodb cluster with wiredTiger
          ../../bin/config-standalone.sh mongodb wiredTiger
          echo "Standalone MongoDB STARTED."

        cd ..
}

function run-ycsb-tests() {
    setup=$1; shift

        cd dsi
          set -e
          set -v
          cd ./clusters/single
          # run ycsb test
          ./bin/mc -config single-ycsb.json -run ycsb-run-${setup} -o perf.json 

    cd ..
}

function run-hammer-tests() {
    setup=$1; shift

        cd dsi
          set -e
          set -v
          cd ./clusters/single
          # run hammer test
          ./bin/mc -config single-hammer.json -run hammer-run-${setup} -o perf.json 

    cd ..
}

function destroy-cluster() {
        cd dsi
          set -e 
          set -o verbose
          cd ./clusters/single
          # configure mongodb cluster with wiredTiger
          yes yes | ./terraform destroy
          echo "Cluster DESTROYED."

    cd ..

}

function test-standalone() {

echo "test standalone "

  # - name: bringup_cluster
  # - name: config_standalone
  # - name: run_ycsb
  # - name: config_standalone
  # - name: run_hammer

}

function test-replica() {
echo "test replica"
  # - name: config_single_member_replica
  # - name: run_ycsb
  # - name: config_single_member_replica
  # - name: run_hammer
  # - name: destroy_cluster
}


test-standalone
test-replica

