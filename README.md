# kutti-images
Instructions to create images for the kutti project

## Versioning
Images will follow the minor version of the kutti project. If the interface between the kutti tool and the image needs to change, a version bump will be required for both.

## Drivers
A separate set of images will have to be maintained for each driver. This project will be updated with build instructions (and where possible, tools and/or scripts) per version, and within that, per driver. In each case, information regarding base components and the kutti interface will be provided alongside the build instructions.

## Kubernetes versions
We will try and maintain images for the current Kubernetes version, and two earlier minor versions. A strategy to deprecate and remove older versions will be created in a while.

## Download source
The releases in this Github project will be the download source for the kutti tool. The tool will download the master list of images, as well as images themselves, from this repo's releases.

## Release procedure
This will be documented shortly.
