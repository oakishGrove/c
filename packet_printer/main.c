#include <stdio.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <string.h>
#include <arpa/inet.h>

#define MAC_LEN 6

struct pkt_t {
    u_int8_t mac[MAC_LEN];
    u_int32_t port;
    struct in_addr srcip;
    struct in_addr dstip;
};

char packet[] = "Mar 4 12:31:43 Teltonika-RUTX11 IN=br-lan OUT=wwan01 MAC=00:00:00:00:00:00 SRC=192.168.1.114 DST=1.1.0.0 LEN=60 TOS=00 PREC=00 TTL=63 ID=170 DF PROTO=TCP SPT=34332 DPT=443 SEQ=267815085 ACK=0 WINDOW=65535 SYN URG P=0 MARK=0";
void parseMac(struct pkt_t *pPkt);
void parsePort(struct pkt_t *pPkt);
void parseIPs(struct pkt_t *pPkt);

char *ipParserHelper();

void printPacket(struct pkt_t* pkt) {
    char macStr[18] = {0};
    char number[4] = {0};
    for (int i = 0; i < MAC_LEN - 1; ++i) {
        sprintf(number, "%02x:", pkt->mac[i]);
        strcat(macStr, number);
    }
    strcat(macStr, number);

    printf("MAC: %s\nPORT: %d\nIN_ADR: %s\nOUT_ADR: %s", macStr, pkt->port, inet_ntoa(pkt->srcip), inet_ntoa(pkt->dstip));
}

int main() {
    struct pkt_t ptk;
    parseMac(&ptk);
    parsePort(&ptk);
    parseIPs(&ptk);
    printPacket(&ptk);
    return 0;
}

void parseIPs(struct pkt_t *pkt) {
    char* srcIp = strstr(packet, "SRC");
    char* spacePos = ipParserHelper("SRC");
    inet_aton(srcIp+4, &pkt->srcip);
    *spacePos = ' ';

    char* dstIp = strstr(packet, "DST");
    spacePos = ipParserHelper("DST");
    printf("!!!! [%s]", dstIp);
    inet_aton(dstIp+4, &pkt->dstip);
    *spacePos = ' ';
    puts(inet_ntoa(pkt->dstip));
}

char *ipParserHelper(char* target) {
    char* srcIp = strstr(packet, target);
    if (srcIp == NULL) {
        perror("SRC not found");
        exit(EXIT_FAILURE);
    }

    char* spacePos = srcIp;
    while(spacePos) {
        if(*spacePos == ' ') {
            *spacePos = '\0';
            break;
        }
        ++spacePos;
    }

    return spacePos;
}

void parsePort(struct pkt_t *pkt) {
    char* srcIp = strstr(packet, "SRC");
    if (srcIp == NULL) {
        perror("SRC not found");
        exit(EXIT_FAILURE);
    }

    char* spacePos = srcIp;
    while(spacePos) {
        if(*spacePos == ' ') {
            *spacePos = '\0';
            break;
        }
        ++spacePos;
    }

    const char* lastDot = strrchr(srcIp+4, '.');
    int val = atoi(lastDot+1);
    pkt->port = val;
    *spacePos = ' ';
}

void parseMac(struct pkt_t *pkt) {
    char* macPos = strstr(packet, "MAC");
    if (macPos == NULL) {
        perror("MAC not found");
        exit(EXIT_FAILURE);
    }
    macPos +=4 ;
    const char* delim = ":";
    char* ptr = NULL;

    char packetCp[sizeof (packet)];
    strcpy(packetCp, packet);

    for (int i = 0; i < MAC_LEN; ++i) {
        ptr = strtok(packetCp, delim);
        char number = atoi(ptr);
        pkt->mac[i] = number;
    }
}
