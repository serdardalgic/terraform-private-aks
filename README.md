# Private AKS Terraform with basic terragrunt integration.

This repo is cloned from [https://github.com/patuzov/terraform-private-aks](https://github.com/patuzov/terraform-private-aks) and adopted to run on different environments like dev/prod.



"Manage a "Fully" private AKS infrastructure with Terraform." explanation in details is in this [medium article](https://medium.com/@paveltuzov/create-a-fully-private-aks-infrastructure-with-terraform-e92358f0bf65?source=friends_link&sk=124faab1bb557c25c0ed536ae09af0a3).

## Running the script

Make sure you have access to the subscription id that you provide.
After you configure authentication with Azure:
```bash
$> cd environments/dev
$> terragrunt run-all plan -out=tfplan.out
....
...
..
$> terragrunt run-all apply "tfplan.out"
```

## Reaching the jump server
```bash
$> terraform output
jumpbox_password = <sensitive>
kube_config = <sensitive>
ssh_command = "ssh azureuser@13.94.158.183"
```

You can print the sensitive values with `terraform output -raw <sensitive_value_name>`

Once you ssh into the jumpbox, you will see a file at home directory called `kube_config_output`.
Export this file as kubeconfig and you'll be able to interact with the K8s
cluster.
```shell
azureuser@jumpboxvm:~$ export KUBECONFIG=kube_config_output
azureuser@jumpboxvm:~$ kubectl get nodes
NAME                              STATUS   ROLES   AGE   VERSION
aks-default-19876247-vmss000000   Ready    agent   56m   v1.23.5
```

## Testing private cluster:
```
azureuser@jumpboxvm:~$ kubectl run busybox --image=busybox -- sleep "3600"
pod/busybox created
azureuser@jumpboxvm:~$ kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          10s
azureuser@jumpboxvm:~$ kubectl exec -it busybox -- sh
/ # wget http://www.google.com
Connecting to www.google.com (142.250.179.132:80)
wget: server returned error: HTTP/1.1 470 status code 470
/ # wget http://www.bing.com
Connecting to www.bing.com (13.107.21.200:80)
saving to 'index.html'
index.html           100% |********************************************************************************************************************************************************************************************************************************| 92233  0:00:00 ETA
'index.html' saved
/ #
```

As expected: external traffic is blocked, but explicit rules can be defined to
allow traffic.
