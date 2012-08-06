[![Build Status](https://secure.travis-ci.org/jwkoelewijn/auditing.png?branch=master)](http://travis-ci.org/jwkoelewijn/auditing)

## Introduction

Small library that builds on the Mordor gem to provide auditing classes

## Usage

Select the database to use, using:

```
Mordor::Config.use do |config|
  config[:database] = 'database'
end
```
