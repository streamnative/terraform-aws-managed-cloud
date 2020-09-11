FROM quay.io/terraform-docs/terraform-docs:0.10.0-rc.1

ADD build_docs.sh /

ENTRYPOINT ["/bin/sh"]
CMD ["/build_docs.sh"]
