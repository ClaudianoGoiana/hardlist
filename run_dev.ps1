param(
    [ValidateSet('run', 'build-apk')]
    [string]$Action = 'run'
)

$SupabaseUrl = $env:SUPABASE_URL
$SupabaseAnonKey = $env:SUPABASE_ANON_KEY

if ([string]::IsNullOrWhiteSpace($SupabaseUrl) -or [string]::IsNullOrWhiteSpace($SupabaseAnonKey)) {
    Write-Error 'Defina SUPABASE_URL e SUPABASE_ANON_KEY no terminal antes de executar o script.'
    Write-Host 'Exemplo:'
    Write-Host '$env:SUPABASE_URL="https://seu-projeto.supabase.co"'
    Write-Host '$env:SUPABASE_ANON_KEY="sua-chave-anon"'
    exit 1
}

if ($Action -eq 'run') {
    flutter run `
        --dart-define=SUPABASE_URL=$SupabaseUrl `
        --dart-define=SUPABASE_ANON_KEY=$SupabaseAnonKey
    exit $LASTEXITCODE
}

flutter build apk `
    --dart-define=SUPABASE_URL=$SupabaseUrl `
    --dart-define=SUPABASE_ANON_KEY=$SupabaseAnonKey
exit $LASTEXITCODE
