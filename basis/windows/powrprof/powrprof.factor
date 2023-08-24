! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.syntax classes.struct kernel math
specialized-arrays system-info windows.errors windows.types
windows.user32 ;
IN: windows.powrprof

LIBRARY: powrprof

TYPEDEF: UINT NTSTATUS
TYPEDEF: void* PHPOWERNOTIFY

CONSTANT: STATUS_SUCCESS 0
CONSTANT: STATUS_ACCESS_DENIED 0xC0000022
CONSTANT: STATUS_BUFFER_TOO_SMALL 0xC0000023

ENUM: SYSTEM_POWER_STATE
    PowerSystemUnspecified
    PowerSystemWorking
    PowerSystemSleeping1
    PowerSystemSleeping2
    PowerSystemSleeping3
    PowerSystemHibernate
    PowerSystemShutdown
    PowerSystemMaximum ;
TYPEDEF: SYSTEM_POWER_STATE* PSYSTEM_POWER_STATE

ENUM: POWER_PLATFORM_ROLE
    PlatformRoleUnspecified
    PlatformRoleDesktop
    PlatformRoleMobile
    PlatformRoleWorkstation
    PlatformRoleEnterpriseServer
    PlatformRoleSOHOServer
    PlatformRoleAppliancePC
    PlatformRolePerformanceServer
    PlatformRoleSlate
    PlatformRoleMaximum ;
TYPEDEF: POWER_PLATFORM_ROLE* PPOWER_PLATFORM_ROLE

ENUM: POWER_INFORMATION_LEVEL
    SystemPowerPolicyAc
    SystemPowerPolicyDc
    VerifySystemPolicyAc
    VerifySystemPolicyDc
    SystemPowerCapabilities
    SystemBatteryState
    SystemPowerStateHandler
    ProcessorStateHandler
    SystemPowerPolicyCurrent
    AdministratorPowerPolicy
    SystemReserveHiberFile
    ProcessorInformation
    SystemPowerInformation
    ProcessorStateHandler2
    LastWakeTime
    LastSleepTime
    SystemExecutionState
    SystemPowerStateNotifyHandler
    ProcessorPowerPolicyAc
    ProcessorPowerPolicyDc
    VerifyProcessorPowerPolicyAc
    VerifyProcessorPowerPolicyDc
    ProcessorPowerPolicyCurrent
    SystemPowerStateLogging
    SystemPowerLoggingEntry
    SetPowerSettingValue
    NotifyUserPowerSetting
    PowerInformationLevelUnused0
    SystemMonitorHiberBootPowerOff
    SystemVideoState
    TraceApplicationPowerMessage
    TraceApplicationPowerMessageEnd
    ProcessorPerfStates
    ProcessorIdleStates
    ProcessorCap
    SystemWakeSource
    SystemHiberFileInformation
    TraceServicePowerMessage
    ProcessorLoad
    PowerShutdownNotification
    MonitorCapabilities
    SessionPowerInit
    SessionDisplayState
    PowerRequestCreate
    PowerRequestAction
    GetPowerRequestList
    ProcessorInformationEx
    NotifyUserModeLegacyPowerEvent
    GroupPark
    ProcessorIdleDomains
    WakeTimerList
    SystemHiberFileSize
    ProcessorIdleStatesHv
    ProcessorPerfStatesHv
    ProcessorPerfCapHv
    ProcessorSetIdle
    LogicalProcessorIdling
    UserPresence
    PowerSettingNotificationName
    GetPowerSettingValue
    IdleResiliency
    SessionRITState
    SessionConnectNotification
    SessionPowerCleanup
    SessionLockState
    SystemHiberbootState
    PlatformInformation
    PdcInvocation
    MonitorInvocation
    FirmwareTableInformationRegistered
    SetShutdownSelectedTime
    SuspendResumeInvocation
    PlmPowerRequestCreate
    ScreenOff
    CsDeviceNotification
    PlatformRole
    LastResumePerformance
    DisplayBurst
    ExitLatencySamplingPercentage
    RegisterSpmPowerSettings
    PlatformIdleStates
    ProcessorIdleVeto
    PlatformIdleVeto
    SystemBatteryStatePrecise
    ThermalEvent
    PowerRequestActionInternal
    BatteryDeviceState
    PowerInformationInternal
    ThermalStandby
    SystemHiberFileType
    PhysicalPowerButtonPress
    QueryPotentialDripsConstraint
    EnergyTrackerCreate
    EnergyTrackerQuery
    UpdateBlackBoxRecorder
    SessionAllowExternalDmaDevices
    SendSuspendResumeNotification
    PowerInformationLevelMaximum ;

STRUCT: BATTERY_REPORTING_SCALE
    { Granularity DWORD }
    { Capacity DWORD } ;
TYPEDEF: BATTERY_REPORTING_SCALE* PBATTERY_REPORTING_SCALE


STRUCT: PROCESSOR_POWER_INFORMATION
    { Number ULONG }
    { MaxMhz ULONG }
    { CurrentMhz ULONG }
    { MhzLimit ULONG }
    { MaxIdleState ULONG }
    { CurrentIdleState ULONG } ;
TYPEDEF: PROCESSOR_POWER_INFORMATION* PPROCESSOR_POWER_INFORMATION

STRUCT: SYSTEM_POWER_CAPABILITIES
    { PowerButtonPresent BOOLEAN }
    { SleepButtonPresent BOOLEAN }
    { LidPresent BOOLEAN }
    { SystemS1 BOOLEAN }
    { SystemS2 BOOLEAN }
    { SystemS3 BOOLEAN }
    { SystemS4 BOOLEAN }
    { SystemS5 BOOLEAN }
    { HiberFilePresent BOOLEAN }
    { FullWake BOOLEAN }
    { VideoDimPresent BOOLEAN }
    { ApmPresent BOOLEAN }
    { UpsPresent BOOLEAN }
    { ThermalControl BOOLEAN }
    { ProcessorThrottle BOOLEAN }
    { ProcessorMinThrottle BYTE }
    { ProcessorThrottleScale BYTE }
    { spare2 BYTE[4] }
    { ProcessorMaxThrottle BYTE }
    { FastSystemS4 BOOLEAN }
    { Hiberboot BOOLEAN }
    { WakeAlarmPresent BOOLEAN }
    { AoAc BOOLEAN }
    { DiskSpinDown BOOLEAN }
    { spare3 BYTE[8] }
    { HiberFileType BYTE }
    { AoAcConnectivitySupported BOOLEAN }
! #else
!  BYTE                    spare3[6];
! #endif
    { SystemBatteriesPresent BOOLEAN }
    { BatteriesAreShortTerm BOOLEAN }
    { BatteryScale BATTERY_REPORTING_SCALE[3] }
    { AcOnLineWake SYSTEM_POWER_STATE }
    { SoftLidWake SYSTEM_POWER_STATE }
    { RtcWake SYSTEM_POWER_STATE }
    { MinDeviceWakeState SYSTEM_POWER_STATE }
    { DefaultLowLatencyWake SYSTEM_POWER_STATE } ;
TYPEDEF: SYSTEM_POWER_CAPABILITIES* PSYSTEM_POWER_CAPABILITIES

ENUM: POWER_ACTION
  PowerActionNone
  PowerActionReserved
  PowerActionSleep
  PowerActionHibernate
  PowerActionShutdown
  PowerActionShutdownReset
  PowerActionShutdownOff
  PowerActionWarmEject
  PowerActionDisplayOff ;
TYPEDEF: POWER_ACTION* PPOWER_ACTION

STRUCT: POWER_ACTION_POLICY
    { Action POWER_ACTION }
    { Flags DWORD }
    { EventCode DWORD } ;
TYPEDEF: POWER_ACTION_POLICY* PPOWER_ACTION_POLICY

CONSTANT: DISCHARGE_POLICY_CRITICAL 0
CONSTANT: DISCHARGE_POLICY_LOW 1
CONSTANT: NUM_DISCHARGE_POLICIES 4

STRUCT: SYSTEM_POWER_LEVEL
    { Enable BOOLEAN }
    { Spare BYTE[3] }
    { BatteryLevel DWORD }
    { PowerPolicy POWER_ACTION_POLICY }
    { MinSystemState SYSTEM_POWER_STATE } ;
TYPEDEF: SYSTEM_POWER_LEVEL* PSYSTEM_POWER_LEVEL

STRUCT: SYSTEM_POWER_POLICY
    { Revision DWORD }
    { PowerButton POWER_ACTION_POLICY }
    { SleepButton POWER_ACTION_POLICY }
    { LidClose POWER_ACTION_POLICY }
    { LidOpenWake SYSTEM_POWER_STATE }
    { Reserved DWORD }
    { Idle POWER_ACTION_POLICY }
    { IdleTimeout DWORD }
    { IdleSensitivity BYTE }
    { DynamicThrottle BYTE }
    { Spare2 BYTE[2] }
    { MinSleep SYSTEM_POWER_STATE }
    { MaxSleep SYSTEM_POWER_STATE }
    { ReducedLatencySleep SYSTEM_POWER_STATE }
    { WinLogonFlags DWORD }
    { Spare3 DWORD }
    { DozeS4Timeout DWORD }
    { BroadcastCapacityResolution DWORD }
    { DischargePolicy SYSTEM_POWER_LEVEL[NUM_DISCHARGE_POLICIES] }
    { VideoTimeout DWORD }
    { VideoDimDisplay BOOLEAN }
    { VideoReserved DWORD[3] }
    { SpindownTimeout DWORD }
    { OptimizeForPower BOOLEAN }
    { FanThrottleTolerance BYTE }
    { ForcedThrottle BYTE }
    { MinThrottle BYTE }
    { OverThrottled POWER_ACTION_POLICY } ;
TYPEDEF: SYSTEM_POWER_POLICY* PSYSTEM_POWER_POLICY


STRUCT: SYSTEM_BATTERY_STATE
    { AcOnLine BOOLEAN }
    { BatteryPresent BOOLEAN }
    { Charging BOOLEAN }
    { Discharging BOOLEAN }
    { Spare1 BOOLEAN[3] }
    { Tag BYTE }
    { MaxCapacity DWORD }
    { RemainingCapacity DWORD }
    { Rate DWORD }
    { EstimatedTime DWORD }
    { DefaultAlert1 DWORD }
    { DefaultAlert2 DWORD } ;
TYPEDEF: SYSTEM_BATTERY_STATE* PSYSTEM_BATTERY_STATE

STRUCT: SYSTEM_POWER_INFORMATION
    { MaxIdlenessAllowed ULONG }
    { Idleness ULONG }
    { TimeRemaining ULONG }
    { CoolingMode UCHAR } ;
TYPEDEF: SYSTEM_POWER_INFORMATION* PSYSTEM_POWER_INFORMATION 


SPECIALIZED-ARRAY: PROCESSOR_POWER_INFORMATION

FUNCTION: NTSTATUS CallNtPowerInformation (
    POWER_INFORMATION_LEVEL InformationLevel
    PVOID                   InputBuffer,
    ULONG                   InputBufferLength,
    PVOID                   OutputBuffer,
    ULONG                   OutputBufferLength
)

FUNCTION: BOOLEAN GetPwrCapabilities (
    PSYSTEM_POWER_CAPABILITIES lpspc
)

FUNCTION: POWER_PLATFORM_ROLE PowerDeterminePlatformRoleEx (
    ULONG Version
)
FUNCTION: DWORD PowerRegisterSuspendResumeNotification (
    DWORD         Flags,
    HANDLE        Recipient,
    PHPOWERNOTIFY RegistrationHandle
)
FUNCTION: DWORD PowerUnregisterSuspendResumeNotification (
    HPOWERNOTIFY RegistrationHandle
)

ERROR: win32-powrprof-error n ;
: win32-power-error ( n -- )
    dup 0 = [ drop ] [ win32-powrprof-error ] if ;

: get-power-capabilities ( -- struct )
    SYSTEM_POWER_CAPABILITIES new
    [ GetPwrCapabilities win32-error=0/f ] keep ;

: get-processor-power-information ( -- structs )
    ProcessorInformation
    f 0
    cpus <PROCESSOR_POWER_INFORMATION-array>
    PROCESSOR_POWER_INFORMATION heap-size cpus *
    [ CallNtPowerInformation win32-power-error ] keepd ;

: simple-call-nt-power-information ( enum class -- struct )
    [ f 0 ] dip
    [ <struct> ] [ heap-size ] bi
    [ CallNtPowerInformation win32-power-error ] keepd ;

: c-type-call-nt-power-information ( enum c-type -- struct )
    [
        [ f 0 ] dip
        [ 0 swap <ref> ] [ heap-size ] bi
        [ CallNtPowerInformation win32-power-error ] keepd
    ] keep deref ; inline

: get-last-sleep-time ( -- nanoseconds )
    LastSleepTime ULONGLONG c-type-call-nt-power-information 100 * ;

: get-last-wake-time ( -- nanoseconds )
    LastWakeTime ULONGLONG c-type-call-nt-power-information 100 * ;

: get-system-execuction-state ( -- enum )
    SystemExecutionState ULONG c-type-call-nt-power-information ;

: get-system-power-capabilities ( -- struct )
    SystemPowerCapabilities SYSTEM_POWER_CAPABILITIES simple-call-nt-power-information ;

: get-system-battery-state ( -- struct )
    SystemBatteryState SYSTEM_BATTERY_STATE simple-call-nt-power-information ;

: get-system-power-policy-ac ( -- struct )
    SystemPowerPolicyAc SYSTEM_POWER_POLICY simple-call-nt-power-information ;

: get-system-power-policy-current ( -- struct )
    SystemPowerPolicyCurrent SYSTEM_POWER_POLICY simple-call-nt-power-information ;

: get-system-power-policy-dc ( -- struct )
    SystemPowerPolicyDc SYSTEM_POWER_POLICY simple-call-nt-power-information ;

