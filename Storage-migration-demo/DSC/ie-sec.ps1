Configuration EnableIEEsc
{
    Import-DSCResource -Module xSystemSecurity -Name xIEEsc
    $server = @('s1','s2')
    Node $server
    {
        xIEEsc EnableIEEscAdmin
        {
            IsEnabled = $false
            UserRole  = "Administrators"
        }
        xIEEsc EnableIEEscUser
        {
            IsEnabled = $false
            UserRole  = "Users"
        }
    }
}
EnableIEEsc -OutputPath c:\dsc\IEESC