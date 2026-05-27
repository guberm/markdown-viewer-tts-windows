# Releases

## Windows installer

Manual GitHub Actions workflow: `windows-release`

Input:
- `tag` - for example `v1.0.0`

Outputs attached to the GitHub release:
- `MarkdownViewerTTS-vX.Y.Z-windows-x64-setup.exe` - Inno Setup installer
- `MarkdownViewerTTS-vX.Y.Z-windows-x64-portable.zip` - portable app bundle

## Notes

The release workflow:
- runs on a real Windows GitHub runner
- executes `flutter analyze`
- executes `flutter test`
- builds the Windows desktop app
- packages an installer with Inno Setup
- creates a GitHub release and uploads both assets
