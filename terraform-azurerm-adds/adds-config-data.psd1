# Derived from https://github.com/adbertram/TestDomainCreator

@{
	AllNodes = @(
		@{
			NodeName = '*'
			PsDscAllowDomainUser = $true
            PsDscAllowPlainTextPassword = $true
		},
		@{
			NodeName = 'localhost'
            Purpose = 'Domain Controller'
            WindowsFeatures = 'AD-Domain-Services', 'RSAT: Active Directory Domain Services and Lightweight Directory Services Tools'
        }
    )
    NonNodeData = @{
        ForestMode = 'WinThreshold'
        AdGroups = 'Accounting','Information Systems','Executive Office','Janitorial Services'
        OrganizationalUnits = 'Accounting','Information Systems','Executive Office','Janitorial Services'
        AdUsers = @(
            @{
                FirstName = 'Katie'
                LastName = 'Green'
                Department = 'Accounting'
                Title = 'Manager of Accounting'
            }
            @{
                FirstName = 'Joe'
                LastName = 'Blow'
                Department = 'Information Systems'
                Title = 'System Administrator'
            }
            @{
                FirstName = 'Joe'
                LastName = 'Schmoe'
                Department = 'Information Systems'
                Title = 'Software Developer'
            }
            @{
                FirstName = 'Tony'
                LastName = 'Stark'
                Department = 'Executive Office'
                Title = 'CEO'
            }
            @{
                FirstName = 'Homer'
                LastName = 'Simpson'
                Department = 'Janitorial Services'
                Title = 'Custodian'
            }
        )
    }
}
