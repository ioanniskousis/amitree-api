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
- credit, to track each user's credit

The following Controllers manage the calls to the API:
- UsersController manages the creation of new users
- AuthenticationController manages the authenticaton of logged in users
- ReferralsController manages the creation of new referral codes by users

The following routes consist the interface:
- post 'register' for the creation of a new user
- post 'authenticate' for authenticating a user
- post 'referral' for the creation of a referral code
- get 'users' to retreive users' index
- get 'user/:id' to retreive a user's info

<br/>

### Registration

A call to the *register* route supplied with data for name, email, password, password confirmation and optionally a referral code is directed to the UsersController at the create method.  
Appropriate validations are performed and a successful creation of a new user renders back a structure containing :
  - auth_token
  - user_id
  - user_name
  - user_email

Validations are performed on model, database, and controller levels.

<br/>

### Authentication

The Token-based Authentication practice is implemented so the <span style="color:orange;">gem jwt</span> was hired to make encoding and decoding of HMACSHA256 tokens  

The authentication token is created at the login procedure and is returned to the caller.  
For this, a call to the *authenticate* route is required suppling data for email and password.  
The data is passed to the JsonWebToken singleton class that validates and successfully creates the token to be supplied to the user. A failure of validating email or password causes the return of a 'invalid credentials' message.  

The return structure includes useful data to be used by the caller.
The content of returned structure:
  - auth_token
  - user_id
  - user_name
  - user_email

<br/>

### Referral Code creation

A call to the *referral* route requires the authentication token to be supplied in the header structure of the request.  
The user is authenticated and a 20 characters length string is generated and returned to the caller.  
If the user has already created a referral code then a 'You Already Have Created A Referral Code' message is returned.  

<br/>

### Users Index

A call to the *users* route requires the authentication token to be supplied in the header structure of the request.  

An array of all users is returned having each item containing the following fields:
  - id
  - name
  - email
  - credit
  - inviter
  - referral_code


<br/>

### User Info

A call to the *user/:id* route requires the authentication token to be supplied in the header structure of the request.  

The following fields are returned:
  - id
  - name
  - email
  - inviter
  - credit
  - referral_code
  - invited_users: an array of users with each containing
      - id
      - name
      - email
      - credit

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
  user_id: id,
  user_name: name,
  user_email: email
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
  user_id: id,
  user_name: name,
  user_email: email
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

The response can be:
1. either a JSON structure:
<br/>

```
{
  referral_code: referral_code
}
```

<br/>

#### 2. Or one of these messages  

```
{
  error: 'Not Authorized'
}

{
  constrain: 'You Already Have Created A Referral Code' 
}
```

<br/>

### Users Index

A GET request is required with header structure containing
- Authorization
  
Note that you have to prefix the authorization token with 'Bearer '  
i.e. 
```
headers: {
          'Authorization': 'Bearer ' + auth_token
         }
```
<br/>


The response can be:
1. either an array of users with the following JSON structure:
<br/>

```
{
  id: user_id,
  name: user_name,
  email: user_email,
  credit: user_credit,
  inviter: user_inviter,
  referral_code: user_referral
}
```

<br/>

#### 2. Or the unauthorized message  

```
{
  error: 'Not Authorized'
}
```

<br/>

### User's Info
A GET request is required with header structure containing
- Authorization
  
Note that you have to prefix the authorization token with 'Bearer '  
i.e. 
```
headers: {
          'Authorization': 'Bearer ' + auth_token
         }
```
<br/>


The response can be:
1. either the following JSON structure:
<br/>

```
{
  id: user_id,
  name: user_name,
  email: user_email,
  inviter: user_inviter,
  credit: user_credit,
  referral_code: user_referral&.code,
  invited_users: array of the invited users
}
```

Note that the invited_users is an array with each element containing:

```
{
  id: user_id,
  name: user_name,
  email: user_email,
  credit: user_credit
}
```

<br/>

#### 2. Or the unauthorized message  

```
{
  error: 'Not Authorized'
}
```
<br/>

<br/>
<hr/>

## Deployment
The API has been deployed on heroku at this address

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
6. The API allows a capable front-end developer to build an application.
   - Samples
     - <a href="https://github.com/ioanniskousis/amitree-interact">A draft example is implemented and is hosted in github</a>
     - <a href="https://ioanniskousis.github.io/amitree-interact/">Live Demo</a>
     - <a href="https://ioanniskousis.github.io/amitree-interact?referral_code=5406a28076fb005f1fe7">Live Demo Sample With Referral Code</a>
     - <a href="https://github.com/ioanniskousis/amitree-react-draft">An implementation with React</a>

** Please note, usually the Heroku is delaying the first call several seconds.

<br/>
<hr/>


<!-- CONTACT -->

## Contributors

:bust_in_silhouette: **Author**

## Ioannis Kousis

- Github: [@ioanniskousis](https://github.com/ioanniskousis)
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

