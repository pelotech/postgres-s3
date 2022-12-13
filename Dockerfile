FROM amazon/aws-cli:2.9.3

LABEL maintainer = "Joachim Hill-Grannec <joachim@pelo.tech>"
RUN amazon-linux-extras install postgresql14

COPY entrypoint.sh /
COPY cmd.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/cmd.sh"]
