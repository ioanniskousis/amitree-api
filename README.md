# Amitree Take Home Technical Challenge

### This project creates an API using Ruby on Rails

<hr/>
<!--
*** Thanks for checking out this README Template. If you have a suggestion that would
*** make this better, please fork the repo and create a pull request or simply open
*** an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
-->

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]

<hr/>
<br/>
<br/>

<!-- TABLE OF CONTENTS -->

## Contents

- [About the Project](#about-the-project)
  
- [Solution](#solution)
  
- [Test](#test)
  
- [Interaction](#interaction)
  
- [Deployment](#deployment)

- [Evaluation](#evaluation)
  
- [Contributors](#contributors)

<hr/>
<br/>
<br/>

<!-- ABOUT THE PROJECT -->

## About the project
<br/>

The project was assigned as a Take Home Technical Challenge by the hiring process of Amitree.  

### The requirements  

The company wants to implement a customer referral program, in order to acquire new paying customers. Here are the product requirements that we are given:

- An existing user can create a referral to invite people, via a shareable sign-up link that contains a unique code  

- When 5 people sign up using that referral, the inviter gets $10.  

- When somebody signs up referencing a referral, that person gets $10 on signup.  
Signups that do not reference referrals do not get any credit.  

- Multiple inviters may invite the same person. Only one inviter can earn credit for a
particular user signup. An inviter only gets credit when somebody they invited signs up; they do not get credit if they invite somebody who already has an account.

<hr/>
<br/>
<br/>

## Solution

Ruby on Rails was used to acheive the solution. So, inintialization was performed by the command
```
rails new amitree-api --api --database=postgresql -T
```

The following models were generated:
- user, to store user's details
- referral, to store the referral codes the users create
- referenced_registrations, to link each user who signs up using a referral code with the creator of the code

The following Controllers manage the calls the the API:
- UsersController manages the creation of new users
- AuthenticationController manages the authenticaton of logged in users
- ReferralsController manages the creation of new referral codes by users

The following routes consist the interface:
- post 'register' for the creation of a new user
- post 'authenticate' for authenticating a user
- post 'referral' for the creation of a referral code

<br/>

### Registration

A call to the *register* route supplied with data for name, email, password, password confirmation and optionally a referral code is directed to the UsersController at the create method.  
Appropriate validations are performed and a successful creation of a new user renders back a structure containing :
- an authentication token 
- the user's name
- in case a referral code was supplied 
  - the inviter's name 
  - and the creadit of $10.  

Validations are performed on model, database, and controller levels.

<br/>

### Authentication

The Token-based Authentication practice is implemented so the <span style="color:orange;">gem jwt</span> was hired to make encoding and decoding of HMACSHA256 tokens  

The authentication token is created at the login procedure and is returned to the caller.  
For this, a call to the *authenticate* route is required suppling data for email and password.  
The data is passed to the JsonWebToken singleton class that validates and successfully creates the token to be supplied to the user. A failure of validating email or password causes the return of a 'Not Authorized' message.  

The return structure includes useful data to be used by the caller.
The content of returned structure:
- autentication token
- user's name
- referral code, if the user has created one
- a list of users that have been invited by the authenticated user
- the amount of credit that corresponds to the invited users
- the amount of $10 credit if the authenticated user has registered using someone's else referral code

<br/>

### Referral Code creation

A call to the *referral* route requires the authentication token to be supplied in the header structure of the request.  
The user is authenticated and a 20 characters length string is generated and returned to the caller.  
If the user has already created a referral code the a 'You Already Have Created A Referral Code' message is returned.  

<br/>
<hr/>

## Test

Test units have been implemented using RSpec to test the requests agains the API.  
Find the units in spec/requests/  

To run tests type on the command prompt
```
rspec --format documentation
```

<br/>
<hr/>

## Interaction

### Registration:  
A POST request is required with body structure containing values for the following

- name
- email
- password
- password_confirmation
- referral_code

<br/>

The response can be 

#### 1. either a JSON structure:

<br/>

```
{
  auth_token: auth_token,
  user_name: user_name,
  inviter_name: inviter_name,
  credit_from_signup: credit_from_signup
}
```

<br/>

#### 2. Or at least one of the following messages
```
error: {
  name: 'is too short (minimum is 4 characters)'
}

error: {
  name: 'can't be blank'
}

error: {
  email: 'is invalid'
}

error: 'email is already registered'

error: {
  password: 'is too short (minimum is 4 characters)'
}

error: {
  password: 'can't be blank'
}

error: 'password does not match password_confirmation'

error: 'Invalid Referral Code'


```

<br/>

### Authentication:  
A POST request is required with body structure containing values for the following

- email
- password

<br/>

The response can be

#### 1. either a JSON structure:

<br/>

```
{
  auth_token: auth_token,
  user_name: user_name,
  inviter_name: inviter_name,
  referral: referral_code,
  invited_users: invited_users,
  credit_from_referral: credit_from_referral,
  credit_from_signup: credit_from_signup
}
```

Note that the invited_users is an array with each element containing:

```
{
  name: user_name,
  email: user_email
}
```

<br/>

#### 2. Or a message
```
error: {
  user_authentication: 'invalid credentials'
}
```

<br/>

### Referral code creation:
A POST request is required with headers structure containing 
- Authorization  
  
Note that you have to prefix the authorization token with 'Bearer '  
i.e. 
```
headers: {
          'Authorization': 'Bearer ' + auth_token
         }
```

<br/>

The response JSON structure:
<br/>
```
{
  auth_token: auth_token
}
```

<br/>
<hr/>

## Deployment
Thye API has been deployed on heroku at this address
```
https://boiling-fjord-82978.herokuapp.com
```

In order to run the API locally, 
- clone this project from the github repository 
- run bundle
- in a case that the database is not downloaded
  - run: rails db:migrate
- and run the rails server
  
<hr/>

## Evaluation
1. The application does have the features to fulfill the requirements and use cases
    - Allows a user to create a referral code
    - Users that sign up using a referral code, they get $10 in credit
    - Signups that do not reference referrals do not get any credit
    - For every 5 people sign up using a referral, the inviter gets $10
    - Only one inviter can earn credit for a particular user signup since email credential is unique in the database and a user can not register twice using the same email address
2. The code is readable and well formated since the use of rubocop gem and self-documenting with comments at parts that need explanation
3. Automated tests are implemented that validate the functionality works as intended
4. The solution is simple and well organized. No extra routes, models, controllers are implemented although a real app in production would require further features 
5. The code is error-resistant and does consider reasonable edge-cases
6. The API allows a capable front-end developer to build an application. An draft example is implemented and is hosted in github at address https://github.com/ioanniskousis/amitree-interact


<br/>
<hr/>


<!-- CONTACT -->

## Contributors

:bust_in_silhouette: **Author**

## Ioannis Kousis

- Github: [@ioanniskousis](https://github.com/ioanniskousis)
- Twitter: [@ioanniskousis](https://twitter.com/ioanniskousis)
- Linkedin: [Ioannis Kousis](https://www.linkedin.com/in/jgkousis)
- E-mail: jgkousis@gmail.com


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/ioanniskousis/amitree-api.svg?style=flat-square
[contributors-url]: https://github.com/ioanniskousis/amitree-api/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/ioanniskousis/amitree-api.svg?style=flat-square
[forks-url]: https://github.com/ioanniskousis/amitree-api/network/members
[stars-shield]: https://img.shields.io/github/stars/ioanniskousis/amitree-api.svg?style=flat-square
[stars-url]: https://github.com/ioanniskousis/amitree-api/stargazers
[issues-shield]: https://img.shields.io/github/issues/ioanniskousis/amitree-api.svg?style=flat-square
[issues-url]: https://github.com/ioanniskousis/amitree-api/issues

