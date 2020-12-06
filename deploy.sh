#!/bin/bash

ansible-playbook -i inventory --extra-vars=@secret.yml playbook.yml
