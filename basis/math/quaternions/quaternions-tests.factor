IN: math.quaternions.tests
USING: tools.test math.quaternions kernel math.vectors
math.constants ;

CONSTANT: q0 { 0 0 0 0 }
CONSTANT: q1 { 1 0 0 0 }
CONSTANT: qi { 0 1 0 0 }
CONSTANT: qj { 0 0 1 0 }
CONSTANT: qk { 0 0 0 1 }

{ 1.0 } [ qi norm ] unit-test
{ 1.0 } [ qj norm ] unit-test
{ 1.0 } [ qk norm ] unit-test
{ 1.0 } [ q1 norm ] unit-test
{ 0.0 } [ q0 norm ] unit-test
{ t } [ qi qj q* qk = ] unit-test
{ t } [ qj qk q* qi = ] unit-test
{ t } [ qk qi q* qj = ] unit-test
{ t } [ qi qi q* q1 q+ q0 = ] unit-test
{ t } [ qj qj q* q1 q+ q0 = ] unit-test
{ t } [ qk qk q* q1 q+ q0 = ] unit-test
{ t } [ qi qj qk q* q* q1 q+ q0 = ] unit-test
{ t } [ qk qj q/ qi = ] unit-test
{ t } [ qi qk q/ qj = ] unit-test
{ t } [ qj qi q/ qk = ] unit-test
{ t } [ 1 c>q q1 = ] unit-test
{ t } [ C{ 0 1 } c>q qi = ] unit-test
{ t } [ qi qi q+ qi 2 q*n = ] unit-test
{ t } [ qi qi q- q0 = ] unit-test
{ t } [ qi qj q+ qj qi q+ = ] unit-test
{ t } [ qi qj q- qj qi q- -1 q*n = ] unit-test

{ { 2 2 2 2 } } [ { 1 1 1 1 } 2 q*n ] unit-test
{ { 2 2 2 2 } } [ 2 { 1 1 1 1 } n*q ] unit-test
