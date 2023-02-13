# Hyperdrive




## Methods

**Auth**
> [POST] /todo

**Service Configuration**
> [GET] /todo

**PID Manipulation**
> [GET] /api/pid/assing_pid
> [GET] /api/pid/assing_pid
> [GET] /api/pid/assing_pid


### Auth 

Metodos para autenticação ???

### Service Configuration

Metodos para configuração

 - Configurar chaves e dos 

### PID Manipulation

	- assing_pid : Desc
	- add_external_pid : 
	- add_external_links : 
	- set_payload : 

#### Assing PID

Retrieve a PID

> [GET] /api/pid/assing_pid

**PARAMETERS**
| Parameter | Description | Type |
|-----------|-------------|------|
| responsable_id  | ID of Section Mapping Authority | String |
 

**RESPONSE**
```
{
	pid : "8003/12345679"
}
```


#### Add External Pid

> [GET] /api/pid/add_external_pid

**PARAMETERS**

| Parameter | Description | Type |
|-----------|-------------|------|
| pid       | pid         | str  |
| external_pids | list of external_pids | json  |

The json of the external_pids should contain a list with all pids that will be added to the PID. Fro example:

``` json 
{ external_pids : ["pid"] }
```

or

``` json 
{ external_links : ["pid1","pid2","pid3"] }
```

**RESPONSE**

 - status:
	- OK
	- QUEUED
	- FAIL
 - job_id : HASH VALUE

``` json
{
	status: "OK",
	job_id:  0x459ad34234ff13
}
```

#### add_external_links

> [GET] /api/pid/add_external_links

**PARAMETERS**

| Parameter | Description | Type |
|-----------|-------------|------|
| pid       | pid         | str  |
| external_links | list of external_links | json  |

The json of the external_links should contain a list with all urls that will be added to the PID. Fro example:

``` json 
{ external_links : ["url"] }
```

or

``` json 
{ external_links : ["url","url","url"] }
```

**RESPONSE**

 - status:
	- OK
	- QUEUED
	- FAIL
 - job_id : HASH VALUE

``` json
{
	status: "OK",
	job_id:  0xab469ad392c4ff13
}
```

#### set_payload

> [GET] /api/pid/set_payload

**PARAMETERS**
| Parameter | Description | Type |
|-----------|-------------|------|
| pid       | pid         | str   |
| payload   | pid metadata | json |
 

**RESPONSE**
```
{
	id: "xxxxx"
}
```


## Grupo