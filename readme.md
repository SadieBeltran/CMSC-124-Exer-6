# OVERVIEW
- 1 NODE THAT STARTS A PROCESS THAT WILL WAIT FOR A MESSAGE FROM ANOTHER NODE
- 1 NODE THAT STARTS A PROCESS THAT WILL NEED **LONG NAME** OF NODE WHERE TO SEND MESSAGE
- NODE 1 AND NODE 2 SHOULD BE ABLE TO SEND MESSAGES TO EACH OTHER WITHOUT THE OTHER HAVING TO REPLY

# TODO
- Make a function that allows two nodes to ping pong with each other
- Node must terminate at bye


## flow
N1 inits chat -> get name from N1
N2 inits chat2 -> getname from N2

Question: When do I get input to send to the other node?

If either N1 or N2 sends "bye", disconnect and stop waiting for node.

When one of the nodes send a message, ping the other node.  

### WHAT IF
N1 inits chat, pings N2 with their pingID
N2 inits chat, pings N1 with their pingID
Make function where N1 just sends stuff to N2 and vice versa
And another separate function wherein if N1 or N2 receives a message they print it out?