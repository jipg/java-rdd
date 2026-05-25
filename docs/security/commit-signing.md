# Commit Signing Guide

<!--
  =============================================================================
  Commit Signing — Verify Author Identity
  =============================================================================

  WHY SIGN COMMITS:
    Unsigned commits only prove that someone with repo access pushed code.
    Signed commits cryptographically prove WHO wrote the code. This is
    critical for:
    - Supply chain security: prevents impersonation attacks
    - Audit trails: regulatory compliance (SOX, PCI-DSS, SOC 2)
    - Trust: GitHub shows a "Verified" badge on signed commits

  TWO METHODS:
    1. GPG signing: traditional, works everywhere, more setup
    2. SSH signing: simpler, uses keys you probably already have

  RECOMMENDATION:
    Use SSH signing if you're on Git 2.34+ (released Nov 2021).
    It's simpler to set up and uses the same SSH key you use for
    GitHub authentication.

  TOOL INFO:
    - Git (built-in feature): free
    - GPG: free (open source, GNU GPL)
    - SSH: free (OpenSSH, BSD license)
    - GitHub verification: free (all plans)
  =============================================================================
-->

## Option 1: SSH Signing (Recommended)

### Prerequisites

- Git 2.34 or later: `git --version`
- An SSH key added to your GitHub account

### Setup

```bash
# 1. Tell Git to use SSH for signing
git config --global gpg.format ssh

# 2. Point to your SSH key (use your actual key path)
git config --global user.signingkey ~/.ssh/id_ed25519.pub

# 3. Enable signing for all commits automatically
git config --global commit.gpgsign true

# 4. Enable signing for all tags automatically
git config --global tag.gpgsign true
```

### Add SSH Key to GitHub as Signing Key

1. Go to GitHub → Settings → SSH and GPG keys
2. Click **New SSH key**
3. Set **Key type** to **Signing Key** (not Authentication)
4. Paste your public key content
5. Click **Add SSH key**

> **Important**: You need the key added as BOTH authentication AND signing
> key types. They are configured separately in GitHub.

### Verify It Works

```bash
# Create a test commit
echo "test" > /tmp/test.txt && git add /tmp/test.txt
git commit -m "test: verify commit signing"

# Check the signature
git log --show-signature -1

# You should see: "Good signature" with your key fingerprint
# Clean up
git reset HEAD~1
```

## Option 2: GPG Signing

### Prerequisites

- GPG installed: `gpg --version`
- A GPG key pair

### Generate GPG Key

```bash
# Generate a new GPG key (use RSA 4096 or Ed25519)
gpg --full-generate-key

# List your keys to find the key ID
gpg --list-secret-keys --keyid-format=long

# Output example:
# sec   ed25519/ABC1234567890DEF 2026-05-20 [SC]
#       FINGERPRINT1234567890ABCDEF1234567890ABCDEF
# uid           [ultimate] Your Name <your.email@example.com>

# The key ID is: ABC1234567890DEF (after the '/')
```

### Setup

```bash
# 1. Tell Git to use GPG
git config --global gpg.format openpgp

# 2. Set your GPG key ID
git config --global user.signingkey ABC1234567890DEF

# 3. Enable automatic signing
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# 4. (macOS only) Configure GPG to use the correct TTY for passphrase prompt
echo 'export GPG_TTY=$(tty)' >> ~/.zshrc
```

### Add GPG Key to GitHub

```bash
# Export your public key
gpg --armor --export ABC1234567890DEF
```

1. Copy the output (including `-----BEGIN PGP PUBLIC KEY BLOCK-----`)
2. Go to GitHub → Settings → SSH and GPG keys
3. Click **New GPG key**
4. Paste the public key
5. Click **Add GPG key**

## Verification in GitHub

Once commit signing and branch protection (`Require signed commits`) are
enabled:

- **Verified** badge: commit is signed with a key linked to the committer's
  GitHub account
- **Unverified** badge: commit is signed but the key is not linked to GitHub
- **No badge**: commit is unsigned — will be **rejected** by branch protection

## CI Considerations

In GitHub Actions, the `actions/checkout` action and the `github-actions`
bot produce commits that GitHub automatically signs. No additional CI setup
is needed.

For other CI systems (Jenkins, Azure DevOps), you'll need to configure a
signing key in the CI environment.

## Troubleshooting

| Problem | Solution |
|---|---|
| "error: gpg failed to sign the data" | Run `export GPG_TTY=$(tty)` or configure pinentry |
| SSH signing shows "No principal matched" | Add your key as a signing key (not just authentication) in GitHub |
| Commits show "Unverified" | Ensure the email in your GPG/SSH key matches your GitHub email |
| macOS keychain prompt issues | `brew install pinentry-mac` and configure `gpg-agent.conf` |
