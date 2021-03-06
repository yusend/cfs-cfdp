PROC scx_cpu3_cf_14534

local logging = %liv (log_procedure)
%liv (log_procedure) = FALSE

#include "ut_statusdefs.h"
#include "ut_cfe_info.h"
#include "cfe_platform_cfg.h"
#include "cfe_evs_events.h"
#include "cfe_es_events.h"
#include "to_lab_events.h"
#include "cf_platform_cfg.h"
#include "cf_events.h"
#include "cfe_tbl_events.h"
#include "tst_cf_events.h"
#include "tst_cf2_events.h"

%liv (log_procedure) = logging

#define CF_6000		0
#define CF_7000		1

global ut_req_array_size = 1
global ut_requirement[0 .. ut_req_array_size]

for i = 0 to ut_req_array_size DO
  ut_requirement[i] = "U"
enddo

;**********************************************************************
; Set the local values
;**********************************************************************
local cfe_requirements[0 .. ut_req_array_size] = ["CF_6000", "CF_7000" ]

;**********************************************************************
; Define local variables
;**********************************************************************
LOCAL rawcmd, stream
local CFAppName = "CF"

write ";***********************************************************************"
write ";  Step 1.0: CFDP Test Setup."
write ";***********************************************************************"
write ";  Step 1.1: Create and upload the table load file for this test.  "
write ";***********************************************************************"
s scx_cpu3_cf_tbl4

;; Parse the filename configuration parameter for the default table
local tableFileName = CF_CONFIG_TABLE_FILENAME
local slashLoc = %locate(tableFileName,"/")

;; loop until all slashes are found
while (slashLoc <> 0) do
  tableFileName = %substring(tableFileName,slashLoc+1,%length(tableFileName))
  slashLoc = %locate(tableFileName,"/")
enddo

write "==> Parsed default Config Table filename = '",tableFileName

;; Upload the default configuration file to CPU3
s ftp_file("CF:0", "cpu3_cf_2upcfg.tbl", tableFileName, "CPU3", "P")

wait 5

write ";***********************************************************************"
write ";  Step 1.2: Display the Housekeeping pages "
write ";***********************************************************************"
page SCX_CPU3_CF_HK
page SCX_CPU3_TST_CF_HK

write ";***********************************************************************"
write ";  Step 1.3: Start the CFDP (CF) and Test (TST_CF) Applications and "
write ";  verify that the housekeeping packet is being generated and the HK "
write ";  data is initialized properly. "
write ";***********************************************************************"
s scx_cpu3_cf_start_apps("1.3")
wait 5

;; Add the HK message receipt test
local hkPktId

;; Set the CF HK packet ID based upon the cpu being used
;; CPU1 is the default
hkPktId = "p0B0"

if ("CPU3" = "CPU2") then
  hkPktId = "p1B0"
elseif ("CPU3" = "CPU3") then
  hkPktId = "p2B0"
endif

;; Verify the HK Packet is getting generated by waiting for the
;; sequencecount to increment twice
local seqTlmItem = hkPktId & "scnt"
local currSCnt = {seqTlmItem}
local expectedSCnt = currSCnt + 2

ut_tlmwait {seqTlmItem}, {expectedSCnt}
if (UT_TW_Status = UT_Success) then
  write "<*> Passed (6000) - Housekeeping packet is being generated."
  ut_setrequirements CF_6000, "P"
else
  write "<!> Failed (6000) - Housekeeping packet sequence count did not increment. Housekeeping packet is not being recieved."
  ut_setrequirements CF_6000, "F"
endif

;; Extract bit 0 of the engine flags and downlink flags
local frozenState = %and(SCX_CPU3_CF_EngineFlags,1)
local pb0QState = %and(SCX_CPU3_CF_DownlinkChan[0].DownlinkFlags,1)
local pb1QState = %and(SCX_CPU3_CF_DownlinkChan[1].DownlinkFlags,1)

;; Check the HK tlm items to see if they are initialized properly
if (SCX_CPU3_CF_CMDPC = 0) AND (SCX_CPU3_CF_CMDEC = 0) AND ;;
   (SCX_CPU3_CF_TotalInProgTrans = 0) AND ;;
   (SCX_CPU3_CF_TotalCompleteTrans = 0) AND ;;
   (SCX_CPU3_CF_TotalFailedTrans = 0) AND (SCX_CPU3_CF_PDUsRcvd = 0) AND ;;
   (SCX_CPU3_CF_PDUsRejected = 0) AND (SCX_CPU3_CF_ActiveQFileCnt = 0) AND ;;
   (SCX_CPU3_CF_GoodUplinkCtr = 0) AND (SCX_CPU3_CF_BadUplinkCtr = 0) AND ;;
   (SCX_CPU3_CF_LastFileUplinked = "") AND ;;
   (SCX_CPU3_CF_PosAckNum = 0) AND (SCX_CPU3_CF_FileStoreRejNum = 0) AND ;;
   (SCX_CPU3_CF_FileChecksumNum = 0) AND (SCX_CPU3_CF_FileSizeNum = 0) AND ;;
   (SCX_CPU3_CF_NakLimitNum = 0) AND (SCX_CPU3_CF_InactiveNum = 0) AND ;;
   (SCX_CPU3_CF_CancelNum = 0) AND (SCX_CPU3_CF_NumFrozen = 0) AND ;;
   (p@SCX_CPU3_CF_PartnersFrozen = "False") AND (frozenState = 0) AND ;;
   (pb0QState = 0) AND (pb1QState = 0) AND ;;
   (SCX_CPU3_CF_DownlinkChan[0].PendingQFileCnt = 0) AND ;;
   (SCX_CPU3_CF_DownlinkChan[1].PendingQFileCnt = 0) AND ;;
   (SCX_CPU3_CF_DownlinkChan[0].ActiveQFileCnt = 0) AND ;;
   (SCX_CPU3_CF_DownlinkChan[1].ActiveQFileCnt = 0) AND ;;
   (SCX_CPU3_CF_DownlinkChan[0].GoodDownlinkCnt = 0) AND ;;
   (SCX_CPU3_CF_DownlinkChan[1].GoodDownlinkCnt = 0) AND ;;
   (SCX_CPU3_CF_DownlinkChan[0].BadDownlinkCnt = 0) AND ;;
   (SCX_CPU3_CF_DownlinkChan[1].BadDownlinkCnt = 0) AND ;;
   (SCX_CPU3_CF_DownlinkChan[0].PDUsSent = 0) AND ;;
   (SCX_CPU3_CF_DownlinkChan[1].PDUsSent = 0) THEN
  write "<*> Passed (7000) - Housekeeping telemetry initialized properly."
  ut_setrequirements CF_7000, "P"
else
  write "<!> Failed (7000) - All Housekeeping telemetry NOT initialized properly at startup."
  ut_setrequirements CF_7000, "F"
  write "CMDPC                  = ", SCX_CPU3_CF_CMDPC
  write "CMDEC                  = ", SCX_CPU3_CF_CMDEC
  write "TotalInProgTrans       = ", SCX_CPU3_CF_TotalInProgTrans
  write "TotalCompleteTrans     = ", SCX_CPU3_CF_TotalCompleteTrans
  write "TotalFailedTrans       = ", SCX_CPU3_CF_TotalFailedTrans
  write "PDUsRcvd               = ", SCX_CPU3_CF_PDUsRcvd
  write "PDUsRejected           = ", SCX_CPU3_CF_PDUsRejected
  write "ActiveQFileCnt         = ", SCX_CPU3_CF_ActiveQFileCnt
  write "GoodUplinkCtr          = ", SCX_CPU3_CF_GoodUplinkCtr
  write "BadUplinkCtr           = ", SCX_CPU3_CF_BadUplinkCtr
  write "LastFileUplinked       = '", SCX_CPU3_CF_LastFileUplinked, "'"
  write "PosAckNum              = ", SCX_CPU3_CF_PosAckNum
  write "FileStoreRejNum        = ", SCX_CPU3_CF_FileStoreRejNum
  write "FileChecksumNum        = ", SCX_CPU3_CF_FileChecksumNum
  write "FileSizeNum            = ", SCX_CPU3_CF_FileSizeNum
  write "NakLimitNum            = ", SCX_CPU3_CF_NakLimitNum
  write "InactiveNum            = ", SCX_CPU3_CF_InactiveNum
  write "CancelNum              = ", SCX_CPU3_CF_CancelNum
  write "NumFrozen              = ", SCX_CPU3_CF_NumFrozen
  write "PartnersFrozen         = ", p@SCX_CPU3_CF_PartnersFrozen
  write "Frozen state           = ",frozenState
  write "Chan 0 Pending Q state = ",pb0QState
  write "Chan 1 Pending Q state = ",pb1QState
  write "Chan 0 PendingQFileCnt = ", SCX_CPU3_CF_DownlinkChan[0].PendingQFileCnt
  write "Chan 1 PendingQFileCnt = ", SCX_CPU3_CF_DownlinkChan[1].PendingQFileCnt
  write "Chan 0 ActiveQFileCnt  = ", SCX_CPU3_CF_DownlinkChan[0].ActiveQFileCnt
  write "Chan 1 ActiveQFileCnt  = ", SCX_CPU3_CF_DownlinkChan[1].ActiveQFileCnt
  write "Chan 0 GoodDownlinkCnt = ", SCX_CPU3_CF_DownlinkChan[0].GoodDownlinkCnt
  write "Chan 1 GoodDownlinkCnt = ", SCX_CPU3_CF_DownlinkChan[1].GoodDownlinkCnt
  write "Chan 0 BadDownlinkCnt  = ", SCX_CPU3_CF_DownlinkChan[0].BadDownlinkCnt
  write "Chan 1 BadDownlinkCnt  = ", SCX_CPU3_CF_DownlinkChan[1].BadDownlinkCnt
  write "Chan 0 PDUsSent        = ", SCX_CPU3_CF_DownlinkChan[0].PDUsSent
  write "Chan 1 PDUsSent        = ", SCX_CPU3_CF_DownlinkChan[1].PDUsSent
endif

wait 5

write ";***********************************************************************"
write ";  Step 1.4: Enable DEBUG Event Messages "
write ";***********************************************************************"
local cmdCtr = SCX_CPU3_EVS_CMDPC + 1

;; Enable DEBUG events for the appropriate applications ONLY
/SCX_CPU3_EVS_EnaAppEVTType Application=CFAppName DEBUG

ut_tlmwait SCX_CPU3_EVS_CMDPC, {cmdCtr}
if (UT_TW_Status = UT_Success) then
  write "<*> Passed - Enable Debug events command sent properly."
else
  write "<!> Failed - Enable Debug events command."
endif

wait 5

write ";***********************************************************************"
write ";  Step 1.5: Uplink a file using CFDP Unacknowledged Mode (Class 1)."
write ";***********************************************************************"
;; Setup for the events to receive
ut_setupevents "SCX", "CPU3", {CFAppName}, CF_IN_TRANS_OK_EID, "INFO", 1
ut_setupevents "SCX", "CPU3", {CFAppName}, CF_CFDP_ENGINE_INFO_EID, "DEBUG", 2
ut_setupevents "SCX", "CPU3", {CFAppName}, CF_CFDP_ENGINE_DEB_EID, "DEBUG", 3

;; Issue the cfdp_dir directive with the appropriate arguments
cfdp_dir "put -class1 class1file.dat 0.24 /ram/class1file.dat"

ut_tlmwait SCX_CPU3_find_event[1].num_found_messages, 1, 60
if (UT_TW_Status = UT_Success) then
  write "<*> Passed (2000;2001) - Class 1 file uplink completed successfully."
  ut_setrequirements CF_2000, "P"
  ut_setrequirements CF_2001, "P"
else
  write "<!> Failed (2000;2001) - Class 1 file uplink did not complete."
  ut_setrequirements CF_2000, "F"
  ut_setrequirements CF_2001, "F"
endif

write "==> Send a raw command with the second uplink channel's MID"
write "==> Enter 'g' or 'go' when completed. "
wait

write ";*********************************************************************"
write ";  Step 2.0: Clean-up - Send the Power-On Reset command.             "
write ";*********************************************************************"
/SCX_CPU3_ES_POWERONRESET
wait 10

close_data_center
wait 75

cfe_startup CPU3
wait 5

write "**** Requirements Status Reporting"
                                                                                
write "--------------------------"
write "   Requirement(s) Report"
write "--------------------------"

FOR i = 0 to ut_req_array_size DO
  ut_pfindicate {cfe_requirements[i]} {ut_requirement[i]}
ENDDO

drop ut_requirement ; needed to clear global variables
drop ut_req_array_size ; needed to clear global variables

write ";*********************************************************************"
write ";  End procedure SCX_CPU3_cf_14534"
write ";*********************************************************************"
ENDPROC
