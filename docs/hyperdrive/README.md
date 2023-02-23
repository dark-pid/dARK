# Hyperdrive

[![](https://mermaid.ink/img/pako:eNpNkV1vgjAUhv9KcxLvkADKx7hYYizTZXNj1N0MvOikmyR8pZZFpv73VQq6XjTve_r2aU97hG2VMvDhm9N6h56jpERy4FmczqKnjXKrKH4MH0jvMIkxCWfzoPdLHC_bmnHMsx_GZVGVRyO0bz4Vdo0RIShOgNR0yxDZNULkbJ8A2lzDCnW1rEyVVvN_1GJ-QS1oTg8tmrNSMH4jqdvf9KrvSPIUbWgCjcf36ISi4O09IOvT9ewlRrpcGRi9HTDSdvuigISvLyQ4SRJoUDBe0CyV73i85BIQO1awBHwpS9YITvMEkvIso7QRFWnLLfiCN0yDpk6pYDijsr8C_C-a72W1puVHVRVDiKWZqPhKfVX3Y10E_CMcwDftO90zLXti2KZru1Jq0MqyM9UN13Jc1zGtiTF1zxr8dlBDdw3PtG3PmFimY1ne-Q8NSZF7?type=png)](https://mermaid.live/edit#pako:eNpNkV1vgjAUhv9KcxLvkADKx7hYYizTZXNj1N0MvOikmyR8pZZFpv73VQq6XjTve_r2aU97hG2VMvDhm9N6h56jpERy4FmczqKnjXKrKH4MH0jvMIkxCWfzoPdLHC_bmnHMsx_GZVGVRyO0bz4Vdo0RIShOgNR0yxDZNULkbJ8A2lzDCnW1rEyVVvN_1GJ-QS1oTg8tmrNSMH4jqdvf9KrvSPIUbWgCjcf36ISi4O09IOvT9ewlRrpcGRi9HTDSdvuigISvLyQ4SRJoUDBe0CyV73i85BIQO1awBHwpS9YITvMEkvIso7QRFWnLLfiCN0yDpk6pYDijsr8C_C-a72W1puVHVRVDiKWZqPhKfVX3Y10E_CMcwDftO90zLXti2KZru1Jq0MqyM9UN13Jc1zGtiTF1zxr8dlBDdw3PtG3PmFimY1ne-Q8NSZF7)

 - problema da data deposito
	- a "data" de criacao do pid fica prejudicada
	- inserir um campo para isso?

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
	- update_pid_metadata : //TODO (nao implementar na primeira POC)

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
