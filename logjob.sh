#!/bin/bash
while true;
do
date >> /opt/temper/log
/opt/temper/temper >> /opt/temper/log
sleep 15m
done

