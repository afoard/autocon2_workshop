# Setup

## Connect Slurpit to NetBox

- Log in to Slurpit and navigate to `Administrator` -> `API keys`
  - Click on `+ Add`
    - You can give your key any name you want
    - Under `Role Permissions` -> `Administrator Access` select choose `Select All`
    - Click `Submit`
    - Click on the copy icon under `Key` and make a note of the key somewhere as we'll need it for the next step



- Log in to NetBox and navigate SLURP'IT -> Settings
  - Under `Data synchronization` choose BOTH and click `Save`
  - Under `Slurp'it server` click `Edit`
    - Enter your Slurp'it URL
    - Enter the Slurp'it API key you made
    - Click `Save`
  - Go to `Data tabs` and under `Planning` click `Sync`
    - You'll now see a populated list of the all the data Slurp'it can reconcile into NetBox
    - Select `All` and then click `Save`




- Connect Netpicker to NetBox

- Put initial state in NetBox or do it in the workshop?