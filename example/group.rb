# clx-agent -r ./example  [-m manager]

# execute `svc -u myservice` command when
# this host takes part in 'mygroup' group
on "+mygroup" do
	`svc -u myservice 2>&1`
end

# execute `svc -d myservice` command when
# this host leaves from 'mygroup' group
on "-mygroup" do
	`svc -d myservice 2>&1`
end

