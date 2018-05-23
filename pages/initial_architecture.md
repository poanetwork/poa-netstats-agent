# POA Net Data App Architecture

POA Networks operates a public platform for smart contracts, including an open Ethereum sidechain with Proof of Authority (PoA) consensus by independent validators (including related governance/security considerations). The POA Network supports decentralized applications (DApps), including a service used to gather and process POA Network Data Application ("POA Net Data App"). This document outlines a draft architecture for an Elixir-based implementation of the POA Net Data App.

<!--ts-->
   * [Summary of Architecture](#summary-of-architecture)
      * [Network Agent Architecture](#network-agent-architecture)
        * [Data Collection](#data-collection)
        * [Data Transfer](#data-transfer)
      * [Network Server Architecture](#network-server-architecture)
        * [Data Aggregation](#data-aggregation)
        * [Data Storage](#data-storage)
        * [Data Reporting](#data-reporting)
        * [Plugins](#plugins)
<!--te-->

# Summary of Architecture

The PAO Net Data App, will be based on a client/server architecture. The network will continue to consist of decentralized group of agents running on client nodes which gather network data and statistics (“Network Agents”). In turn, this data and stats will be aggregated and stored in a time series database by a central server (“Network Server”), which will connect with a public-facing interface used to report these statistics configurable northbound APIs such as as proprietary dashboards, monitoring tools or SaaS services. This architecture will be implemented using Elixir best practices intended to eventually support 30,000 active agents, all sending data at regular intervals.

This architecture is intended to ideally be implemented in a phased manner, allowing incremental development. The Agent will initially be implemented to interface with the existing Server; and subsequently, the existing Server will be replaced with an Elixir-based implementation. Once the Server implementation is completed, additional enhancements and new interfaces in both the Agent and the Server will be possible (see section 1.2.4). They could be standards such as StatsD, Syslog and SNMP or proprietary standards. Additional discovery will need to be done as to POA Network’s internal development workflow and tooling; however,
Elixir offers deployment tooling which can ideally be implement in conjunction with or in lieu of existing tooling.

Where and when possible, this architecture re-uses existing code/applications. For instance, it appears that the current public-facing reporting interface is written in AngularJS, which is presumably decoupled from the current Central Server NodeJS application. As such, this AngularJS application can ideally be re-used and configured to work with the Central Server Elixir application.

## Network Agent Architecture

The initial implementation of the Architecture will involve replacing the existing
Agent with a new Elixir-based solution. This implementation will take advantage of Elixir best
practices to allow for a decoupled and distributed architecture with improved reliability and
scalability (e.g,. reduced data loss and downtime); which can be further enhanced once the
Server has been implemented.

The Agent will gather, store and transmit a variety of network data, including both
Ethereum Client statistics and other node data (e.g., cpu usage, memory, network, etc.) in the
form of metrics, logs and alarms. The Agent will be architected to use separate Elixir modules^1
which perform key functionality, including: data collection, temporary data storage, northbound
data transfer, and application monitoring.

### Data Collection

The most essential functionality of the Agent will be to collect data from the POA network (nodes. The Agent can be architected in a manner that allows for data of different format and sources to be collected concurrently. The agent can be extended to manage multiple industry standards such as Syslog, StatsD and SNMP, allowing it to be used with other tools, as well as proprietary APIs allowing it to efficiently interface the Server 1.1.2 Temporary Data Storage

In the initial Agent implementation, data will initially be persisted in a local database native to Elixir/OTP ([Mnesia](http://erlang.org/doc/man/mnesia.html)). This approach will address the data loss concern of intermittent network outages. Data can be removed either once it has been sent, or when the server acknowledges receipt, or on a configurable wrap around schedule so as to not fill up the hard drive.

### Data Transfer

The initial implementation of the Agent will employ the existing protocol and API to expose the Data it has gathered/stored to the existing Server for aggregation and reporting. This approach will allow the existing NodeJS Central Server to continue to be used. The protocol and API will be implemented as a plugin, allowing others to be added.Once the Elixir-based Server is implemented, the Agent can be extended to use different upstream transfer of data.

The Agent can continue to use WebSockets for communications where suitable. However, where appropriate, it can export different standards which point. For instance, with respect to [logging data network protocol](https://en.wikipedia.org/wiki/Syslog#Network_protocol), it is likely that Syslog sent over UDP is used. Similarly, to the extent that alarm/alert notifications are implemented, it’s likely that [Simple Network Management Protocol (SNMP)](https://en.wikipedia.org/wiki/Simple_Network_Management_Protocol#Protocol_details) will be used. For metrics, StatsD is a common standard supported by many tools.

## Network Server Architecture

This architecture contemplates that the Server App will be implemented either concurrently with or (more likely) subsequent to the implementation of the Agent. Much like the Agent, the Server will also leverage Elixir best practices to decouple key functionality within the application, and deliver improved performance, scalability, reliability, resilience, and fault tolerance. The Server will be architected to use separate Elixir modules which perform key functionality, including: data aggregation, data storage, data reporting, application monitoring, and application extensions (e.g., for analysis). The Server will initially implement a minimal multi-node architecture. In due course, that implementation can evolve as the network grows to implement a multi-tier node architecture and more advance distributed architecture patterns. The net result will be a “system that never stops”, and which can scale from the current dozens of nodes to the planned thousands of nodes.

### Data Aggregation

The Server will be responsible for consuming Data from the Agent nodes on the network. This architecture will employ a consumer/producer model using Elixir tooling to implement with backpressure and load regulation([GenStage](https://hexdocs.pm/gen_stage/GenStage.html), so as to ensure application availability and performance. As the network grows, this multi-node architecture can grow to permit aggregation of data from an essentially infinite number of Agent nodes on the network. As mentioned above, once both the Agent and Server have been implemented, the two can be tightly integrated to ensure the integrity of the data aggregation.

### Data Storage

The data which is aggregated on the the Server will be persisted in a data store for purposes of reporting and analysis. The architecture will employ a lightweight wrapper around the datastore, so as to abstract which datastore is used and provide flexibility. It is likely that, at least initially, the architecture will use Elixir’s official database wrapper, [Ecto](https://hexdocs.pm/ecto/Ecto.html). While it’s possible that AWS DynamoDB could be used as a datastore (as mentioned in the [draft specifications](https://github.com/poanetwork/RFC/issues/7)), the architecture will most likely recommend evaluating and selecting a Time Series Database and/or other datastore(s) which are best suited to the given functionality needed. The key objective of this aspect of the architecture is to decoupling the business logic from the persistence layer, so as to facilitate data/code portability, flexibility and maintainability.

### Data Reporting

The proposed architecture will decouple the reporting dashboard from the data aggregation and storage functionality. As noted at the outset, this architecture will also aim to interface with and re-use the existing public-facing reporting application/dashboard, which appears to be implemented in AngularJS. Elixir provided excellent functionality to ensure that the data can be effectively retrieved from the datastore(s) and exposed to the reporting dashboard.

### Plugins

We understand that plans exist to add additional functionality to the platform, much of which is currently a work in progress. As such, the proposed architecture contemplates abstracting such northbound API functionality into a series of modules that can service as “plug-ins” to extend the platform. This approach will expose data and/or other Elixir functionality as needed via these plugins (e.g., Grafana analytics/monitoring, further data analysis, etc.); and there is also potential for external developers to create plugins that could connect with the platform.
