---
theme: night
---

# Supply Chain Attacks

### Signer ici

---

> "Dance like nobody is watching.  
> Encrypt like everyone is."  
> 
> Neil R. Wiler (@grifter801)  
> Bart Stump (@theStump3r)  
> Black Hat 2015

---

# ToC

- $ whoami
- Desjardins
- Avertissements
- Supply-Chain Attacks
    - Intégrité
- Code-based Supply Chain Attacks

---

<!-- .slide: data-background="imgs/color-wheel-768x676.png" -->
# $ whoami

---

<!--![Desjardins](imgs/desjardins.svg)-->

![Ristourne](imgs/ristourne.jpg)

---

### Avertissement
- Les opinions exprimées dans la présente présentation sont celles de l'auteur.  
- Elles ne prétendent pas refléter les opinions ni n'engagnent d'aucune façon le mouvement Desjardins ou ses filiales

--

![ubuntu](https://turnoff.us/image/en/super-power-extra.png)

---

![Shutdown](https://turnoff.us/image/en/security-expert.png)

--

### Sécurité: Fromage Suisse

![Fromage Suisse](imgs/Swiss_cheese_model.svg)

Par BenAveling - Oeuvre Propre, CC BY-SA 4.0, https://commons.wikimedia.org/w/index.php?curid=91881875

---

### Supply Chain Attacks

```mermaid
flowchart LR

C([Code]) --> B[Build Artifacts] -->|Push| R[Registry] -->|Pull| P([Prod]) & T[Tests]
T -.->|Pass| P
E([External Libraries]) -->|Pull| B & T

style C color:#4C4,stroke:#4C4
style E color:#CC4,stroke:#CC4
```

--

# Intégrité

![Freshness Seal](imgs/freshness-seal.png)

source: https://www.labelsonline.co.uk/jar-seal-labels-sealed-for-freshness-se1087

--

### Hachage

```mermaid
flowchart LR
M -.-> H
M([message]) --> A[Algo] --> H([Hash / Digest])
M2([messsage]) -->A --> O([Autre Digest])
M2 -.-> O
```

--

### En Code

```typescript
import { createHash } from 'crypto'
createHash('sha256')
    .update('Lorem Ipsum')
    .digest()
    .toString('base64')
// 'Aw3B+TbDQVr/PzNXFjUVGQ00eijnWOH3F9F7rkU1Qck='
```

--

### package-lock.json

```json
{
  "lockfileVersion": 3,
  "packages": {
    "node_modules/@sambego/diorama": {
      "version": "1.1.4",
      "resolved": "https://registry.npmjs.org/@sambego/diorama/-/diorama-1.1.4.tgz",
      "integrity": "sha512-BvdUclMexhy+kw2k5ylFw/N1ioOtdviKMhxIWAURFSs9xP6SrLTUO/6jbDMBzyLl/pur+i9nVfwC7oy5F23PMQ==",
    },
  }
}
```

---

### Confiance?

Le hachage permet de garantir:
- L'exactitude d'une copie
- L'intégrité d'une information en transport
- L'exactitude d'un installateur

--

### Confiance?

Aucune garantie **à l'origine**:
- Intégrité de la source d'information
    - ex: Version Malicieuse (ex: faker@6.6.6)
- Validité de la source d'information
    - Interception/Substitution (ex: MitM)

--

### Collisions (MD5 & SHA1)

```mermaid LR
flowchart LR
V[/valid.txt/] -->A[Algo] --> H([Base64])
E[\evil.txt\]  -->A
style E color:#C44,stroke:#C44
```

---

### Supply Chain Attack: Code

```mermaid
flowchart LR

C([Code]) --> B[Build Artifacts] -->|Push| R[Registre] -->|Pull| P([Prod]) & T[Tests]
T -.->|Pass| P
```

--

# Non-Répudiation

![Signature Justin](imgs/Signature_Justin_Trudeau.svg)

source: https://commons.wikimedia.org/wiki/File:Signature_Justin_Trudeau.svg

--

Non couvert: Menaces internes

![tech Layoffs](imgs/layoffs.jpg)

---

### Git AuthN !== Commit Author/Commiter Validation

```mermaid
gitGraph
    commit
    commit tag: "v1.0.0"
    branch fork
    commit
    checkout main
    commit
    checkout fork
    commit
    checkout main
    commit tag: "v1.0.1"
    checkout fork
    merge main
```

--

# Demo

### Impersonation

--

# Demo

### Rewrite

https://github.com/jayphelps/git-blame-someone-else

--

# La Morale

Un [poste de] dev compromis...

---

### Authenticité

![Authenticity Seal](imgs/authenticity-seal.png)

https://www.lr-origine.com/qui-sommes-nous/

--

```mermaid
flowchart LR

subgraph Signature
    PK(["🔑 Privée"]) --> A
    M([Message]) --> A[Algo] --> S([Signature])
end

subgraph Validation
    S --> V{Validation} -.-> O(["✅"])
    M & Pub(["🔑 Publique"]) --> V
    V -.-> N(["🚮"])
end
```

--

### En Code

```typescript 
import { generateKeyPairSync, createSign, createVerify } from 'crypto'
const { privateKey, publicKey } = generateKeyPairSync('ec', {
  namedCurve: 'sect239k1',
});

const sign = createSign('SHA256');
sign.write('some data to sign');
sign.end();
const signature = sign.sign(privateKey, 'hex');

const verify = createVerify('SHA256');
verify.write('some data to sign');
verify.end();
console.log(verify.verify(publicKey, signature, 'hex'));
// Prints: true
```

Source: https://nodejs.org/dist/latest-v18.x/docs/api/crypto.html#class-sign

---

`/salt/states/users/gfournier.sls`
```diff
gfournier:
+ user.absent:
- user.present:
-   uid: 4005
-   groups:
-     - wheel

```

--

> Les serveurs protestent la mise à pied de Gab!
>
> - Sara Line Boucher, Dev FOCUS

--

<!-- .slide: data-visibility="hidden" -->
```mermaid
sequenceDiagram

participant D as DockerD
participant S as Sentry
participant L as Service λ

note over D: Did Not Start
D --> S: Did Not Start
L --> S: Waiting...

Note over D: Tweak Config
D -->> D: Starts
D -->> S: Start
S -->> L: Response
Note over L: Start
```

--

### Root Cause

`/etc/docker/daemon.json`
```diff
{
+  "data-root": "/mnt/docker"
-  "graph": "/mnt/docker"
}
```

--

### Améliorations Possibles

| Service       | Instrumenté | Alerte |
|---------------|-------------|--------|
| Services      |      ✅     |   ✅   |
| Sentry        |      🔌     |   🔌   |
| Docker Daemon |      ✅     |   🔌   |

---

### Commit Signing

- GPG
- SSH
- X.509

Plus d'info: https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key

---

#### Install GnuPG

Windows: https://www.gpg4win.org/download.html

Mac: `brew install gpg`

Linux: `$ sudo apt install gpg gpg-agent`
(Probablement déà préinstallé)

--

### Generate new GPG key

> $ gpg --full-generate-key

--

### List Keys

> $ gpg --list-secret-keys --keyid-format=LONG
```{data-trim data-line-numbers="1|2|3"}
sec   ed25519/69BD15E0783D13C1 2023-04-26 [SC] [expires: 2025-04-25]
      79AF64C47A0DF9E8BABFC3AF69BD15E0783D13C1
uid                 [ultimate] Test Key <test@test.test>
```

--

### Exporter la clé publique

> $ gpg --armor --export 69BD15E0783D13C1

```
-----BEGIN PGP PUBLIC KEY BLOCK-----
...
-----END PGP PUBLIC KEY BLOCK-----
```

--

### [Upload au service git](https://github.com/settings/keys)

--

### Git

```sh
git config --global user.signingkey 69BD15E0783D13C1
git config --global commit.gpgsign true
```

--

### VSCode

```json
{
    "git.enableCommitSigning": true
}
```

---

# Demo!

### Keygen

---

> Signing every commit is stupid.  
> Only sign golden commits
>
> Linus Torvals ~2010 (reconstitué)

--

# [SHA1ttered](shattered.io)

--

# Automatismes {class="r-fit-text"}

---

| Signing                       | Sign Off        |
|-------------------------------|-----------------|
| --S [key]                     | -s              |
| --gpg-sign [key]              | --signoff       |
| -----BEGIN PGP SIGNATURE-----<br/>...<br/>-----END PGP SIGNATURE----- | `Signed-off-by` |

---

# Push signing

Merci [MrIcon](https://people.kernel.org/monsieuricon/signed-git-pushes)


--

```mermaid
gitGraph
    commit
    branch error
    commit id:"Error: Do Not Push To Prod"
    commit id:"Error Handling"
    checkout main
    merge error
    commit tag: "v1.0.1"
```

--

### Push Signing: Activer Client-Side

```
git config --global push.signing if-asked
```

--

### Push Signing: Activer Server-Side

### git >= 2.2.0
`/etc/gitconfig`
```
[receive]
    advertisePushOptions = true
    certNonceSeed = "<uniquerandomstring>"
```

--

### Push Signing: Activer Server-Side

- *Gitea*: [Unofficial](https://github.com/go-gitea/gitea/issues/13454)
- *GitLab*: Feature Flag
- *GitHub*: [Requested](https://github.com/orgs/community/discussions/23515)

---

```mermaid
flowchart LR

N([Notaire]) -.->|Clés| B & R & P
C([Code]) --> B[Build Artifacts] -->|Push| R[Registre] -->|Pull| P([Prod]) & T[Tests]
T -.->|Pass| P
E([External Libraries]) -->|Pull| B & T
```

---

> доверяй, но проверяй  
> (Trust, but verify)

---

# Sources

Sauf expressément noté, la majorité des cartoons utilisés proviennent de:
- turnoff.us

---

# Questions?

# Commentaires? {class="r-fit-text"}

# Insultes?

---

<!-- .slide:data-background="imgs/bonfire.gif" -->
## Bonne St-Jean! {class="r-fit-text"}

