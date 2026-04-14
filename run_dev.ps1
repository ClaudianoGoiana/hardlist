param(
    [ValidateSet('run', 'run-web', 'build-apk')]
    [string]$Action = 'run',
    [string]$AnonKey
)

$SupabaseUrl = $env:SUPABASE_URL
$SupabaseAnonKey = if ([string]::IsNullOrWhiteSpace($AnonKey)) { $env:SUPABASE_ANON_KEY } else { $AnonKey }

if ([string]::IsNullOrWhiteSpace($SupabaseUrl)) {
    $SupabaseUrl = 'https://zlfhxcksweffglpjelci.supabase.co'
}

$isPlaceholderKey = $SupabaseAnonKey -eq 'TEMP_DEBUG_KEY' -or
    $SupabaseAnonKey -like '*SUA_CHAVE_ANON*' -or
    $SupabaseAnonKey -like '*sua-chave-anon*'

if ([string]::IsNullOrWhiteSpace($SupabaseAnonKey) -or $isPlaceholderKey) {
    $SupabaseAnonKey = Read-Host 'Cole sua SUPABASE_ANON_KEY (anon public key)'
    $isPlaceholderKey = $SupabaseAnonKey -eq 'TEMP_DEBUG_KEY' -or
        $SupabaseAnonKey -like '*SUA_CHAVE_ANON*' -or
        $SupabaseAnonKey -like '*sua-chave-anon*'

    if ([string]::IsNullOrWhiteSpace($SupabaseAnonKey) -or $isPlaceholderKey) {
        Write-Error 'Chave ANON invalida. Use a anon public key real do projeto Supabase.'
        exit 1
    }
}

$env:SUPABASE_URL = $SupabaseUrl
$env:SUPABASE_ANON_KEY = $SupabaseAnonKey

if ($Action -eq 'run') {
    flutter run `
        --dart-define=SUPABASE_URL=$SupabaseUrl `
        --dart-define=SUPABASE_ANON_KEY=$SupabaseAnonKey
    exit $LASTEXITCODE
}

if ($Action -eq 'run-web') {
    flutter run -d chrome `
        --dart-define=SUPABASE_URL=$SupabaseUrl `
        --dart-define=SUPABASE_ANON_KEY=$SupabaseAnonKey
    exit $LASTEXITCODE
}

flutter build apk `
    --dart-define=SUPABASE_URL=$SupabaseUrl `
    --dart-define=SUPABASE_ANON_KEY=$SupabaseAnonKey
exit $LASTEXITCODE
