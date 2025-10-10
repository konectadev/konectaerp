#!/bin/bash
echo "project_id = \"${{ secrets.PROJECT_ID }}\"" > terraform.tfvars
echo "region     = \"${{ secrets.REGION }}\"" >> terraform.tfvars