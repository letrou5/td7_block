pragma solidity >=0.4.22<0.6.0;

contract ticketingSystem{



  struct Ticket {
   
    uint idticket;
    address owner;
    uint date;
    uint id_venue;
    uint id_artist;
    uint concertId;
    uint amountPaid;
    bool isAvailable;
    bool isAvailableForSale;
  }

  mapping(uint256 => Ticket) public ticketsRegister;
  mapping(address => uint) public pendingTransactions;
  bool public releaseEther;
  uint public ticketPrice;
  address public venueOwner;
  bytes32 public name_tick;
  event TicketKey(bytes32 ticketKey);
  event CanPurchase(bool canPurchase);
  event PaidFor(bool paid);

mapping (uint256 => Artist) public artistsRegister;

struct Artist
{
  address owner;
  uint id;
  bytes32 name;
  uint artistCategory;
  uint totalTicketSold;
}

uint artistCounter = 1 ;//compteur
uint venueCounter = 1 ;
uint ticketCounter = 1 ;
uint concertcounter = 1 ;



function createArtist (bytes32 nam, uint genr) public
{
  artistsRegister[artistCounter].owner=msg.sender;
  artistsRegister[artistCounter].name=nam;
  artistsRegister[artistCounter].artistCategory=genr;
  artistsRegister[artistCounter].id=artistCounter;
  artistsRegister[artistCounter].totalTicketSold=0;
  artistCounter++;
}

function modifyArtist(uint ido,bytes32 nam,uint newgenr,address a )public
{
  require(artistsRegister[ido].owner==msg.sender);
  artistsRegister[ido].owner=a;
  artistsRegister[ido].name=nam;
  artistsRegister[ido].artistCategory=newgenr;
  artistsRegister[ido].totalTicketSold=0;
  

}
mapping (uint256 => Venue) public venuesRegister;


struct Venue
{
  uint id;
  address owner;
  bytes32 name;
  uint capacity;
  uint standardComission;
}

function createVenue (bytes32 nam, uint cap, uint comi) public
{
  venuesRegister[venueCounter].id=venueCounter;
  venuesRegister[venueCounter].owner=msg.sender;
  venuesRegister[venueCounter].name=nam;
  venuesRegister[venueCounter].capacity=cap;
  venuesRegister[venueCounter].standardComission=comi;
  venueCounter++;
}


function modifyVenue(uint ido,bytes32 nam,uint cap,uint comi,address a )public
{
  require(venuesRegister[ido].owner==msg.sender);
  venuesRegister[ido].owner=a;
  venuesRegister[ido].name=nam;
  venuesRegister[ido].capacity=cap;
  venuesRegister[ido].standardComission=comi;
  
}

function createTicket(uint idart,uint idven,uint dat,uint _concertid,address a )public
{
  ticketsRegister[ticketCounter].concertId=_concertid;
  ticketsRegister[ticketCounter].amountPaid=concertsRegister[_concertid].prixticket;
  ticketsRegister[ticketCounter].isAvailable=true;
  ticketsRegister[ticketCounter].isAvailableForSale=false;
  ticketsRegister[ticketCounter].owner=a;
  ticketsRegister[ticketCounter].id_artist=idart;
  ticketsRegister[ticketCounter].id_venue=idven;
  ticketsRegister[ticketCounter].date=dat;
  ticketsRegister[ticketCounter].idticket=ticketCounter;
  ticketCounter++;

}

mapping (uint256 => Concert) public concertsRegister;

struct Concert
{
  uint artistId;
  uint concertDate;
  uint venueId;
  uint prixticket;
  bool validatedByArtist;
  bool validatedByVenue;
  uint totalSoldTicket;
  uint totalMoneyCollected;
}

function createConcert (uint idar, uint idve, uint dat,uint tickpri) public
{

  concertsRegister[concertcounter].artistId=idar;
  concertsRegister[concertcounter].concertDate=dat;
  concertsRegister[concertcounter].venueId=idve;
  concertsRegister[concertcounter].prixticket=tickpri;
  concertsRegister[concertcounter].validatedByVenue=false;
  concertsRegister[concertcounter].totalSoldTicket=0;
  concertsRegister[concertcounter].totalMoneyCollected==0;

  if(concertcounter%2==0)
  {concertsRegister[concertcounter].validatedByArtist=false;}
 else
 { concertsRegister[concertcounter].validatedByArtist=true;}
  concertcounter++;
}


function validateConcert(uint _concertId) public {

require(concertsRegister[_concertId].concertDate >= now);

if (venuesRegister[concertsRegister[_concertId].venueId].owner == msg.sender)
{
concertsRegister[_concertId].validatedByVenue = true;
}
if (artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender)
{
concertsRegister[_concertId].validatedByArtist = true;
}
}


function emitTicket(uint concertid,address payable _ticketOwner) public
{

  require(msg.sender==artistsRegister[artistCounter-1].owner);

  createTicket(concertsRegister[concertid].artistId,concertsRegister[concertid].venueId,
    concertsRegister[concertid].concertDate,concertid,_ticketOwner);

  concertsRegister[concertid].totalSoldTicket++;

 // emit deploy(artistsRegister[artistCounter],tickets[ticketCounter]);
}



function buyTicket(uint _concertId) public payable
{

  createTicket(concertsRegister[_concertId].artistId,concertsRegister[_concertId].venueId ,
   concertsRegister[_concertId].concertDate, _concertId,msg.sender);
  
  concertsRegister[_concertId].totalSoldTicket++;
  concertsRegister[_concertId].totalMoneyCollected+=concertsRegister[_concertId].prixticket;


}

function useTicket(uint _ticketId) public
{
  
  require(msg.sender==ticketsRegister[_ticketId].owner);
  
    ticketsRegister[_ticketId].isAvailable=false;
    ticketsRegister[_ticketId].owner=address(0x0000);
}  

function transferTicket(uint _ticketId, address payable _newOwner) public
{
  require(msg.sender==ticketsRegister[_ticketId].owner);
  ticketsRegister[_ticketId].owner=_newOwner;

}

function cashOutConcert(uint _concertId, address payable _cashOutAddress) public
{
  require(concertsRegister[_concertId].concertDate<uint256(now) );


}




  modifier onlyOwner() {
    require(msg.sender == venueOwner);
    _;
  }

  modifier notOwner() {
    require(msg.sender != venueOwner);
    _;
  }

  modifier releaseTrue() {
    require(releaseEther);
    _;
  }

  function Tickets(uint price,bytes32 title)public{
    ticketPrice = price;
    name_tick = title;
    venueOwner = msg.sender;
    releaseEther = false;
  }

  function ()external{
    releaseEther = false;
  }

  function allowPurchase() onlyOwner public {
    releaseEther = true;
    emit CanPurchase(releaseEther);
  }

  function lockPurchase() onlyOwner public{
    releaseEther = false;
   emit CanPurchase(releaseEther);
  }
/**
  function createTicket() payable notOwner public{
    if (msg.value == ticketPrice) {
      pendingTransactions[msg.sender] = msg.value;
      bytes32 hash = keccak256(abi.encode(msg.sender));
      tickets[hash] = Ticket(false, msg.sender);
      emit TicketKey(hash);
    }
  }**/

}