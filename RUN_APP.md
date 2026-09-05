# P2P Showrooms App - Run Instructions

## Quick Start

### Option 1: Run batch file (Windows)
```
Double-click: run.bat
```

### Option 2: Run PowerShell script
```powershell
.\run.ps1
```

### Option 3: Manual command
```powershell
flutter run -d chrome --dart-define=SUPABASE_URL=https://ozvxovlwwctwbiwcfdfy.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_Yg61yWR4ix_kGGEVGEeHgg_wL_rFIBT
```

## Supabase Configuration

**Project URL:** https://ozvxovlwwctwbiwcfdfy.supabase.co

**Current Setup:**
- ✅ Email OTP authentication enabled
- ✅ Email template: "Your P2P verification code: {{ .Token }}"
- ✅ SMTP: Resend
- ⏳ Phone OTP: To be configured with SMS provider
- ⏳ Home screen: In development
- ⏳ Admin panel: In development

## Important Security Notes

- **Publishable Key** (`sb_publishable_...`) is safe for mobile/web apps
- **Service Role Key** must NEVER be exposed in client code
- Rotate credentials if they're shared or compromised
- Never commit `.env` files or credentials to Git

## Next Steps

1. ✅ Email OTP signup/login working
2. ⏳ Home screen after successful login
3. ⏳ User profile and logout
4. ⏳ Showrooms database schema
5. ⏳ Admin panel

Happy coding! 🚀
