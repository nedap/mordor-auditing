[![CircleCI](https://circleci.com/gh/nedap/mordor-auditing/tree/master.svg?style=svg)](https://circleci.com/gh/nedap/mordor-auditing/tree/master)

## Introduction

Small library that builds on the Mordor gem to provide auditing classes

## Usage

Select the database to use, using:

```
Mordor::Config.use do |config|
  config[:database] = 'database'
end
```
