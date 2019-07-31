# Automation-Test-Framework
Linux automated testing framework

一. Running tests

To run these tests on your local machine :

./Run.sh -a

Run only performance tests (config/*.xml) :

./Run.sh -f benchmark.xml

二. Writing tests

  Feel free to add the test modules you want to make. For example, the "Linux Command" test. You can create the "commands" folder in the testcases directory. And add the corresponding xml file in the config directory.
    
  There is an xml parsing script in the lib folder. Use "source xmlParse.sh" if necessary
