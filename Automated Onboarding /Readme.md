# Automated Onboarding 

A meticulously designed workflow harnessing the power of automation through Azure Logic Apps, seamlessly orchestrating the creation of user profiles, dynamic group assignments, and efficient document delivery. Leveraging the synergy between Azure Logic Apps and Microsoft Entra ID, this streamlined process ensures swift and error-free execution, enhancing operational efficiency while providing a seamless experience for user onboarding and document management

# Architecture

![architecture](https://github.com/Enzeiy/Azure-Projects/blob/main/Automated%20Onboarding%20/Images/OnboardingProjectcpng.png)

# Pre-requisites
  - Microsoft Azure Account and Subscription
  - Postman API platform Account
  - Outlook Account

# Resources
  - Azure Logic App
  - Azure Microsoft Entra ID
  - Postman API
  - Outlook 

# Procedures

1. Microsoft Entra ID

   This section allows you to create the necessary requirements such as tenants, users, groups, and assign the proper roles during the onboarding process

   - Create a new tenant in your current azure subscription. The created tenant will be used during the assignment of user principal names.
   - Create the necessary groups where the onboarded users will be assigned.

3. Logic Application Workflow
  
   The logic app workflow will automate the creation of user when is receives a HTTP request from a onboarding platform, after the user creation the workflow will
   send a welcoming email to the user.

   - Create a logic app resource, add a blank logic app workflow
   - Locate the designer blade, and add a HTTP trigger

![Workflow](https://github.com/Enzeiy/Azure-Projects/blob/main/Automated%20Onboarding%20/Images/Workflow.png)
    

- HTTP Request Trigger
  
    - on the HTTP request trigger, set the method as POST
    - Create and enter your sample JSON payload, then click Save
    - Review the created JSON scheme and copy the URL generated by the trigger

 ![HTTP](https://github.com/Enzeiy/Azure-Projects/blob/main/Automated%20Onboarding%20/Images/HTTP_Payload.png)

- Microsoft Entra ID connector
    - After the HTTP request trigger, search and add a Microsoft Entra ID, create user connector
    - Add new parameters such as Job Title, Office Location, and others if applicable
    - fill-in the necessary parameter using the dynamic content feature.

![ENTRA](https://github.com/Enzeiy/Azure-Projects/blob/main/Automated%20Onboarding%20/Images/Entra.png)
      
- Condition Trigger
   - Add a condition action and set the logic function to AND.
   - Input the necessary data and operators for the AND function.
   - Add the 'add user to group' action for both conditions, true or false.
   - On the 'add user to group' action, provide the unique identifier of both, the group object id and the user id.

![CONDITION](https://github.com/Enzeiy/Azure-Projects/blob/main/Automated%20Onboarding%20/Images/Condtion.png)

- Email Connector
   - connect an email connector at the end of the workflow.
   - compose the body of your welcoming email, utilize the dynamic content feature to automate the filling in of necessary information of the created user.
   - use the dynamic content feature to enter the email of the newly created user.

![Email](https://github.com/Enzeiy/Azure-Projects/blob/main/Automated%20Onboarding%20/Images/Email.png)

    
3. Postman API Platform

   The Postman API platform will simulate the delivery of the payload using an HTTP request to trigger the Azure Logic App workflow.
   
   - Open Postman API platform in your browser, login and create a new collection.
   - set the method to Post, and paste the URL from the HTTP request trigger.
   - access the body tab, configure the data type as raw, and enter the sample payload used in creating the JSON schema in the HTTP request trigger.

  ![Postman](https://github.com/Enzeiy/Azure-Projects/blob/main/Automated%20Onboarding%20/Images/Postman.png)

4. Workflow Verification

   This section will be a guide to simulate the automated onboarding workflow using the postman api.

   - On your Azure Logic App workflow, locate the workflow designer blade, click the 'run trigger' on the ribbon.
   - After running the trigger, on the postman api click 'send' to initiate the delivery of the payload.
   - review the workflow and check for any errors

   ![VWORK](https://github.com/Enzeiy/Azure-Projects/blob/main/Automated%20Onboarding%20/Images/verify_workflow.png)

   - Go to the overview blade of the logic app workflow, and review the run history.

   ![Vover](https://github.com/Enzeiy/Azure-Projects/blob/main/Automated%20Onboarding%20/Images/verify_overview.png)

   - Go to Microsoft Entra ID, locate the group tab, and go to the members blade to verify that the user has been created and has been assign to the right group

   ![VGroup](https://github.com/Enzeiy/Azure-Projects/blob/main/Automated%20Onboarding%20/Images/Verify%20User.png)

   - Login and access the outlook account of the created user, verify that the user has received the welcoming email.

   ![Vmail](https://github.com/Enzeiy/Azure-Projects/blob/main/Automated%20Onboarding%20/Images/Verify_Email.png)

6. Improvements



  

