#!/bin/bash
sudo -H -u postgres psql -d parkingdata -c 'UPDATE public."Cities" SET "City" = '\''Timisoara'\'' WHERE "CityID"='\''TMS'\'';'
