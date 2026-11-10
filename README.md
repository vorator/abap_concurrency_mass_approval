# SAP ABAP RAP: Mass Approval with Background Processing (bgPF) & Concurrency Control

An enterprise-grade transactional application built on SAP S/4HANA using the ABAP RESTful Application Programming Model (RAP). This project demonstrates a robust OData V4 implementation highlighting Optimistic Locking and the offloading of heavy mass actions to the Background Processing Framework (bgPF), ensuring a non-blocking UI and strict concurrency protection.

## 🎯 Business Use Case
In a real-world Shared Service Center (SSC) during Month-End Close, financial teams do not approve invoices one by one. They select hundreds of invoices at once. Processing complex validations synchronously blocks the user's browser, leading to HTTP 504 Timeout errors, and creates critical race conditions if two accountants attempt to modify the same list simultaneously.

**Key business capabilities:**
- **Non-Blocking UI (Mass Processing):** Instantly frees the user's Fiori interface when approving hundreds of invoices, delegating the heavy execution to an asynchronous background thread.
- **Concurrency Control (Optimistic Locking):** Automatically evaluates ETag timestamps. If User A has an invoice open and User B attempts a mass approval, the RAP framework inherently rejects the concurrent transaction, protecting the HANA database.
- **Enterprise UX Standards:** Provides immediate, unobtrusive UI feedback (Fiori grouped messages) while the background engine processes the workload silently.

## 🏗️ Technical Architecture (Clean Core)
This solution strictly adheres to SAP's Clean Core principles, replacing obsolete RFC background tasks (`CALL FUNCTION ... IN BACKGROUND TASK`) with modern Object-Oriented APIs:
- **Data Model & Concurrency:** Core Data Services (CDS) utilizing `@Semantics.systemDateTime.localInstanceLastChangedAt` to establish the ETag master for Optimistic Locking.
- **Behavior Definition (BDEF):** Managed implementation with Draft capabilities, strict concurrency locking (`lock master`), and a dedicated `with additional save` phase to safely register asynchronous jobs.
- **Background Processing Framework (bgPF):** Utilization of `cl_bgmc_process_factory` and `if_bgmc_op_single` to securely attach background jobs to the primary Logical Unit of Work (LUW).

## ⚙️ Execution Flow & Class Architecture
To comply with strict RAP transactional contracts, the logic is highly decoupled into distinct processing phases:

### 1. The Behavior Pool (`ZBP_I_CONC_INVOICE`)
Acts as the gatekeeper, splitting the logic between UI interaction and the transactional save sequence.
* **Phase 1: Interaction (`lhc_Invoice->approveInvoice`)**
  * **Role:** Synchronous validation.
  * **Action:** Quickly verifies if selected invoices are in 'Pending' status, provides immediate Fiori UI feedback (Information toast), and securely parks the valid Invoice IDs in a static memory buffer. It **never** triggers the background job directly to avoid breaking the RAP contract.
* **Phase 2: Save Sequence (`lsc_Invoice->save_modified`)**
  * **Role:** Transactional job registration.
  * **Action:** Triggered only when the primary LUW is safely committing. It reads the static buffer, instantiates the background class, and calls `save_for_execution()`. If the main transaction fails, the background job silently aborts.

### 2. The Background Worker (`ZCL_CONC_BG_INVOICE_APPROVE`)
Acts as the asynchronous engine, running in a completely isolated thread.
* **Phase 3: Asynchronous Execution (`if_bgmc_op_single~execute`)**
  * **Role:** Heavy lifting and Database Update.
  * **Action:** Receives the payload (Invoice IDs), simulates intensive business validations, and uses Entity Manipulation Language (EML / `MODIFY ENTITIES`) to update the invoice status to 'Approved'. 
  * *Clean Core Note:* Does not use explicit `COMMIT ENTITIES`, as the bgPF framework intelligently auto-commits upon successful execution or auto-rollbacks if an exception is raised.

## 📸 Showcase
### 1. Fiori Elements UI (OData V4 & Background Action)
<img width="1912" height="547" alt="image" src="https://github.com/user-attachments/assets/57d21215-c359-479b-95d5-92a82a42f3d8" />

<img width="1916" height="547" alt="image" src="https://github.com/user-attachments/assets/b2ede295-648f-4808-8118-4978d7ce87ca" />

## 🛠️ Key Features Implemented
- [x] **Background Processing Framework (bgPF):** Safe delegation of heavy mass actions without blocking the UI, replacing legacy asynchronous RFCs.
- [x] **Optimistic Locking (ETags):** Built-in race-condition prevention across the OData V4 stack using `LastChangedAt` semantics.
- [x] **Strict RAP Phase Adherence:** Proper separation of the Interaction Phase (`FOR MODIFY`) and the Save Sequence (`with additional save` / Saver Class) using static memory buffers.
- [x] **Entity Manipulation Language (EML):** Headless background execution of database updates leveraging the RAP business object framework.

## 👨‍💻 About the Developer
I am an IT Engineer and Software Developer specializing in SAP ABAP, S/4HANA architecture, and Java.
With a robust background integrating cross-border financial systems and ERPs (SAP, Navision, SAGE), I build resilient technical solutions grounded in deep business process understanding.
[🔗 Connect with me on LinkedIn](https://linkedin.com/in/luispinto82/) | 💻 **GitHub:** [@vorator](https://github.com/vorator)
