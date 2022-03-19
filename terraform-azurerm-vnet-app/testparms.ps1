#! /usr/bin/pwsh

param (
    [Parameter(Mandatory = $true)]
    [String]$Firstname,

    [Parameter(Mandatory = $true)]
    [String]$Middlename,

    [Parameter(Mandatory = $true)]
    [string]$Lastname
)

Write-Host "$Firstname $Middlename $Lastname"
