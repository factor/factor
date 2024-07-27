! Copyright (C) 2023 Sebastian Strobl.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax combinators system classes.struct ;

IN: vulkan

! TODO: this will be auto generated in the future, this is just to test glfw
TYPEDEF: u32 SampleMask
TYPEDEF: u32 Bool32
TYPEDEF: u32 Flags
TYPEDEF: u64 Flags64
TYPEDEF: u64 DeviceAddress
TYPEDEF: u64 DeviceSize

TYPEDEF: uintptr_t Handle

TYPEDEF: Handle Instance 
TYPEDEF: Handle PhysicalDevice
TYPEDEF: Handle SurfaceKHR

ENUM: Result
 { VK_SUCCESS 0 }
 { VK_NOT_READY 1 } ;


STRUCT: AllocationCallbacks 
  { pfn_allocation void* } ;
