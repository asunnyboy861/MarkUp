# Pricing Configuration

## Monetization Model: Free + IAP Subscription

## App Store Connect Pricing
- **Price Tier**: Free (Download)

## Free Tier Features
- Magnifier/Loupe Tool
- Shape Tools (circle, rect, triangle, star) with fill/outline toggle
- Arrow Tool (free angle)
- Text Annotation (basic fonts)
- Free Drawing (Pen, Marker, Pencil)
- Highlight Tool
- Blur/Pixelate Tool
- Opacity Adjustment
- Tool Memory
- Photo Library Import
- Camera Capture
- Share Extension Import
- Export (PNG/JPG)
- Undo/Redo
- Color Picker
- Basic colors (8 preset colors)

## Premium Subscription Features
- Batch Editing (multi-image annotation)
- Template/Presets (save and apply annotation templates)
- PDF Export
- Custom Color Palette (full spectrum + recent colors)
- All font styles and sizes
- Advanced shape styles (shadow, custom border)
- No watermark on exports

## Subscription Group
- **Group Name**: MarkUp Pro
- **Group ID**: MarkUp_Pro

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: MarkUp Pro Monthly
- **Product ID**: `com.zzoutuo.MarkUp.monthly`
- **Price**: $2.99 per month
- **Display Name**: MarkUp Pro Monthly
- **Description**: Unlock batch editing, templates & PDF export
- **Localization**: English (US)

### 2. Yearly Subscription
- **Reference Name**: MarkUp Pro Yearly
- **Product ID**: `com.zzoutuo.MarkUp.yearly`
- **Price**: $14.99 per year (58% savings vs monthly)
- **Display Name**: MarkUp Pro Yearly
- **Description**: Unlock batch editing, templates & PDF export
- **Localization**: English (US)

### 3. Lifetime Purchase
- **Reference Name**: MarkUp Pro Lifetime
- **Product ID**: `com.zzoutuo.MarkUp.lifetime`
- **Price**: $29.99 one-time
- **Display Name**: MarkUp Pro Lifetime
- **Description**: One-time purchase, unlock all Pro features
- **Note**: No ongoing costs for this app (no server/API costs)

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to paid monthly)

## Policy Pages Required
- Support Page: ✅
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms included in Terms
- [x] Cancellation instructions included
- [x] Pricing clearly stated
- [x] Free trial terms included
- [x] Restore purchases functionality implemented
- [x] No dark patterns in Paywall
- [x] Subscription management link in Settings

## Paywall Design Notes
- Show feature comparison (Free vs Pro)
- Highlight yearly savings percentage
- Include Privacy Policy and Terms links
- Restore Purchases button visible
- No manipulative urgency language
