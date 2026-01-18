#!/usr/bin/env python
"""
Script to exchange OAuth authorization code for tokens
Usage: python exchange_oauth_code.py <authorization_code>
"""
import sys
import os
import json
from google_auth_oauthlib.flow import InstalledAppFlow

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from mcp_google_sheets.server import SCOPES, CREDENTIALS_PATH, TOKEN_PATH

def exchange_code_for_tokens(auth_code: str):
    """Exchange authorization code for tokens"""
    try:
        flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_PATH, SCOPES)
        
        # Exchange the authorization code for tokens
        # We need to set the redirect_uri to match what was used in the auth URL
        # run_local_server uses http://localhost:PORT/ as redirect_uri
        flow.redirect_uri = 'http://localhost:3600/'  # Default port used by run_local_server
        
        creds = flow.fetch_token(code=auth_code)
        
        # Save the credentials
        os.makedirs(os.path.dirname(TOKEN_PATH) if os.path.dirname(TOKEN_PATH) else '.', exist_ok=True)
        with open(TOKEN_PATH, 'w') as token:
            token.write(creds.to_json())
        
        print(f"✓ Successfully authenticated! Tokens saved to {TOKEN_PATH}")
        return True
    except Exception as e:
        print(f"✗ Error exchanging code for tokens: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python exchange_oauth_code.py <authorization_code>")
        print("Or provide full URL: python exchange_oauth_code.py <full_oauth_callback_url>")
        sys.exit(1)
    
    input_arg = sys.argv[1]
    
    # If it's a full URL, extract the code
    if input_arg.startswith('http'):
        from urllib.parse import urlparse, parse_qs
        parsed = urlparse(input_arg)
        params = parse_qs(parsed.query)
        if 'code' in params:
            auth_code = params['code'][0]
            print(f"Extracted authorization code from URL")
        else:
            print("✗ No 'code' parameter found in URL")
            sys.exit(1)
    else:
        auth_code = input_arg
    
    success = exchange_code_for_tokens(auth_code)
    sys.exit(0 if success else 1)





