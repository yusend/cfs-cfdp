# cFS: CCSDS File Delivery Protocol (CFDP)

[![GitHub release](https://img.shields.io/github/release/lassondesat/cfs-cfdp.svg)](https://github.com/lassondesat/cfs-cfdp/releases)

* [Original README](cfs-cf-app-OSS-readme.txt)

## Description

The CCSDS File Delivery Protocol (CFDP) application (CF) is a core Flight System
(cFS) application that is a plug in to the Core Flight Executive (cFE) component
of the cFS.

The cFS is a platform and project independent reusable software framework and
set of reusable applications developed by NASA Goddard Space Flight Center. This
framework is used as the basis for the flight software for satellite data
systems and instruments, but can be used on other embedded systems. More
information on the cFS can be found at http://cfs.gsfc.nasa.gov

The CF application is used for transmitting and receiving files. To transfer
files using CFDP, the CF application must communicate with a CFDP compliant
peer.

CF sends and receives file information and file-data in Protocol Data Units
(PDUs) that are compliant with the CFDP standard protocol defined in the CCSDS
727.0-B-4 Blue Book. The PDUs are transferred to and from the CF application via
CCSDS packets on the cFE's software bus middleware.

## Requirements

* [Operating System Abstraction Layer][osal] 4.1.1 or higher
* [core Flight Executive][cfe] 6.4.1 or higher

## Sources

* https://sourceforge.net/projects/cfs-cfdp/

[osal]: https://github.com/lassondesat/osal
[cfe]: https://github.com/lassondesat/coreflightexec
