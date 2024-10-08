$params = @{
    Credential = Get-Credential
    CAType              = "EnterpriseSubordinateCA"
    CryptoProviderName  = "RSA#Microsoft Software Key Storage Provider"
    KeyLength           = 2048
    HashAlgorithmName   = "SHA256"
    ValidityPeriod      = "Years"
    ValidityPeriodUnits = 3
}
Install-AdcsCertificationAuthority @params