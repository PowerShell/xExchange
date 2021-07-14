@{
    # Set up a mini virtual environment...
    PSDependOptions             = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = ''
        }
    }

    Sampler                     = 'latest'
    invokeBuild                 = 'latest'
    PSScriptAnalyzer            = 'latest'
    pester                      = '4.10.1'
    Plaster                     = 'latest'
    ModuleBuilder               = '1.0.0'
    MarkdownLinkCheck           = 'latest'
    ChangelogManagement         = 'latest'
    'DscResource.Test'          = '0.14.1'
    'DscResource.AnalyzerRules' = 'latest'
    xDscResourceDesigner        = 'latest'
    'DscResource.Common'        = '0.9.3'
    'xPendingReboot'            = '0.4.0'
    'xWebAdministration'        = '3.1.1'
}
