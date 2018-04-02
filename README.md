# Nebula

This project aims to provide a full featured Cloud Data Management (CDMI) API
for data storage andretrieval. More information on CDMI, including the latest
CDMI reference, can be found at the [`Storage Network Industry Association's`](http://www.snia.org)
[`CDMI Cloud Storage Standard`](https://www.snia.org/cloud/cdmi) webpage.

The CDMI standard defines an API for storing, retrieving, modifying and deleting
data and related objects in the cloud. Related objects include:

  * containers for organizing data objects (analogous to file system directories)
  * domains for providing administrative ownership of objects
  * queues for first-in, first-out access to data
  * system-wide capabilities objects that define features of the cloud storage system.

Objects stored in the cloud storage system can then be accessed either by path
or by the object identifier, a globally unique identifier assigned at object
creation time. This identifier does not change during the life of the object.
The CDMI standard also allows (but does not require) the cloud storage system
to provide data management services such as:

  * Exported protocols, such as iSCSI, Webdav, etc.
  * Snap shots - point-in-time copies of containers and their contents
  * Serialization/deserialization for bulk movement of data into or out of a cloud
  * Metadata, including Access Control Lists for authorization, and user defined
    metadata
  * Retention and hold management
  * Logging
  * Scope and results specifications
  * Notification and query queues

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
