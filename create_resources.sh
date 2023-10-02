#!/bin/bash

## To be modified ##
REGISTRY="quay.mylab.local/bigimages"
CONTAINERS="2"
BIGFILESIZE="1"
####################


echo "Creating a big file and a Dockerfile"

rm -f Dockerfile 2> /dev/null
fallocate -l ${BIGFILESIZE}G big-file

cat >> Dockerfile << EOL
FROM docker.io/library/alpine
COPY big-file .
RUN apk add --no-cache bash
EOL

#echo -e "Choose the required action:\n 1: create both images and deployment.yaml\n 2: Create images only\n 3: Create deployment.yaml only\n 4: Delete created images and deployment.yaml file"
echo -e "Choose the required action:\n 1: create both images and deployment.yaml\n 2: Create images only\n 3: Create deployment.yaml only"
read INPUT

if [[ $INPUT == "1" ]] ; then

        echo "Building container images"

	COUNT=0

	while [[ $COUNT -lt $CONTAINERS ]] ; do
	
		podman build --squash-all . -t $REGISTRY/my-test-image-$COUNT
		podman push $REGISTRY/my-test-image-$COUNT --tls-verify=false
		((COUNT++))
	done
	
	echo "Building the deployment.yaml file"

        cp deployment_original.yaml deployment.yaml

	COUNT=0

        while [[ $COUNT -lt $CONTAINERS ]] ; do
        cat >> deployment.yaml << EOL
      - args:
        - tail
        - -f
        - /dev/null
        name: my-test-container-$COUNT
        imagePullPolicy: IfNotPresent
        image: $REGISTRY/my-test-image-$COUNT
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
EOL
	        ((COUNT++))
	done

elif [[ $INPUT == "2" ]] ; then
        echo "Building container images"
        CONTAINERS=5

	COUNT=0

        while [[ $COUNT -lt $CONTAINERS ]] ; do

                podman build --squash-all . -t my-test-image-$COUNT
                ((COUNT++))

        done

elif [[ $INPUT == "3" ]] ; then
        echo "Building the deployment.yaml file"

        cp deployment_original.yaml deployment.yaml

	COUNT=0

        while [[ $COUNT -lt $CONTAINERS ]] ; do
        cat >> deployment.yaml << EOL
      - args:
        - tail
        - -f
        - /dev/null
        name: my-test-container-$COUNT
        imagePullPolicy: IfNotPresent
        image: $REGISTRY/my-test-image-$COUNT
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
EOL
                ((COUNT++))
	done
else
	echo DOING NOTHING
fi
