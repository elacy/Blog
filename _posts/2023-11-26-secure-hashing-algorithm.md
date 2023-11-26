---
title: Secure Hashing Algorithm Explained
layout: post
categories:
  - Technology
tags:
  - Security
  - Cryptography
---

![](/assets/images/2023/11/26/hash.png "I asked Chat GPT to create an artistic visualisation of SHA as a grinder")

A cryptographic hashing function or CHF is a one-way mathematical function that allows you to ensure that it's not possible to get back to the original value that was put in but also that it should have a very low probability of producing the same output for two different values. Secure Hashing Algorithm is one of the most popular CHFs; the first version was created by the NSA back when they were cool. This blog post will explain how it works and why it works that way.<!-- more -->

So there are many uses for a cryptographic hashing algorithm, including:
- Creating a signature of the original contents so we know the decryption went OK
- Hashing passwords: if we store your password in a database, then it can be stolen; not so much if we hash your password along with a random seed value so it can't be compared to other entries
- Signing Documents, running RSA against an entire document would require a key larger than the document (check my [blog post on RSA](/technology/2023/11/18/rsa-by-example.html)), so instead, we can run a hash on the document and sign the output.
- Random Number Generation (ensures the randomness has a normal distribution)

To be effective as a hashing algorithm, it needs the following:

- Collision Resistance: It needs to be able to find two inputs that produce the same hash; I can't verify that my decryption worked if any value I get back has a high probability of making the same hash
- Preimage Resistance: Finding any input that hashes to a specific output should be computationally infeasible. If someone else can figure out what I put into the hash based on the hash, then my encryption is broken.
- Second Preimage Resistance: Even if it's computationally infeasible that I will find the original value, I shouldn't be able to find anything that can produce a specific output, which is essential for validating cryptographic signatures.
- Avalanche Effect: If I change one bit in the message, it should cause a significant change in the output, ensuring you can't know that you are close to the correct answer by looking at the output.
- Uniform Distribution: The outputs should appear random in that there should be no correlation between input and output
- Cryptanalysis Resistance: It should not be vulnerable to known attacks like differential or linear cryptanalysis.

OK, so how does it work? Well, you can imagine it like shuffling cards; the more different types of mechanisms you use to shuffle the cards, the more likely it is to change how it was initially distributed. However, for SHA in particular, it's best to imagine yourself pouring the word into a grinder piece by piece after breaking it up by hand. Each version of SHA gets progressively more complex, so I'll start with the most straightforward and earliest versions (SHA-0 and SHA-1), and we will work towards SHA-2.

## SHA-0
SHA-0 was withdrawn by the NSA two years after publication, but it is more straightforward than SHA-2, so it's an excellent place to start learning.

### Padding
Before we start hashing, this SHA requires the message length to be evenly divisible by 512, and it needs to end with the number of bits in the original message $$\bmod{2^{64}}$$. So you add a 1 to the end of the message and a series of zeros until there is enough room for a 64-bit number before the total bits become divisible by 512.

```
import struct

# Data is an array of bytes
def pad(data):
    original_length = len(data) * 8 # Length in bits
    data += b"\x80"  # Append a bit '1' and seven '0' bits.

    while length_in_bits(data) % 512 != (512 - 64):
        data += b"\x00" # Add zero to the end

    data += struct.pack('>Q', original_length) # Append original length in bits mod (2^64) to message

    return data
```

### Outer Loop
So SHA-0 outputs 160 bits at the end, 5x 32-bit values concatenated together. At the start, we are going to initialise those values to the following:
```
v = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0]
```

Then, for each 512-bit block, we copy those five values, grind up our 512 bits into them, and finally add the result to our original values; here is some code that may help make it clear:

```
def sha(data):
    data = pad(data)

    v = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0]

    for i in range(0, length_in_bits(data), 512):
        block = data.read(64) # Read 64-bytes or 512 bits

        # This is explained in the next section
        result = grind(block, v.copy()) 

        for i in range(0, len(h)):
            # Add them together and ignore anything above 32-bits
            v[i] = (result[i] + v[i]) & 0xffffffff 

    return ''.join(['%08x' % i for i in v]) # Return all the values concatenated
```

### Expansion
The first step is to expand the 64-byte block into 320 bytes; this will place more emphasis on the right-hand side of the block, but don't worry, the later part of the grind will balance that out.

```
def expand(block):
    w = struct.unpack('!16L', block) # Turn block into series of 16 unsigned longs (4 bytes each)
    w += [0] * (80 - len(w)) # We are going to expand this from 16 to 80

    for i in range(16, 80):
        w[i] = word[i-3] ^ w[i-8] ^ w[i-14] ^ w[i-16] # Trailing XORs

    return w

```

### Main Loop or Grind (as I like to call it)
OK here is where the meat of the hash function happens. 

```
# Shift the number to the left and wrap everything that falls off the end
def rotate(n, b):
    return ((n << b) | (n >> (32 - b))) & 0xffffffff

def grind(block, init_values):
    w = expand(block)
    a, b, c, d, e = init_values

    for i in range(80):
        if 0 <= i <= 19:
            f = (b & c) | ((~b) & d) # Choose Function
            k = 0x5A827999
        elif 20 <= i <= 39:
            f = b ^ c ^ d # XORs
            k = 0x6ED9EBA1
        elif 40 <= i <= 59:
            f = (b & c) | (b & d) | (c & d) # AND OR
            k = 0x8F1BBCDC
        elif 60 <= i <= 79:
            f = b ^ c ^ d # XORs
            k = 0xCA62C1D6
    
        # We add a single word (4 bytes) into the grind
        grinded = rotate(a, 5) + f + e + k + w[i] & 0xffffffff 

        # Rotate the middle
        b = rotate(b, 30) 

        # e gets drops off the end, we push everything right and 
        # add the grinded piece on the end
        a,b,c,d,e = grinded,a,b,c,d 

    return [a, b, c, d, e]
```

## SHA-1
So, two years after SHA-0 was released, someone realized there was a bug in the code, but they didn't tell anyone what that bug was. However, in 2008, [Xiaoyun Wang](https://en.wikipedia.org/wiki/Xiaoyun_Wang), [Yiqun Lisa Yin](https://en.wikipedia.org/wiki/Yiqun_Lisa_Yin), and Hongbo Yu showed that applying the boomerang attack meant you could find collisions in $$2^{33.6}$$ operations, which was estimated to take 1 hour on an average PC from the year 2008. The only change is in the expansion function; it left-rotates the words by 1. Which, of course, completely changes the outcome.

```
def expand(block):
    w = [int.from_bytes(block[i:i+3]) for i in range(len(block), 4)]
    w += [0] * (80 - len(w)) 

    for i in range(16, 80):
        w[i] = rotate(w[i-3] ^ w[i-8] ^ w[i-14] ^ w[i-16], 1)

    return w

```

## SHA-2
If you, for some reason, imagined that no one would be able to get the original values back from SHA-1, you would be wrong. Never underestimate the power of math nerds.

### Initialisation
So first of all, instead of outputting 160 bits, it outputs 256bits so the initialisation values are as follows:

```
v = [ 
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
]
```

### Rotation
Instead of doing a leftward rotation, we switch to rightward

```
# Shift the number to the right and wrap everything that falls off the end
def rotate(value, amount):
    return ((value >> amount) | (value << (32 - amount))) & 0xFFFFFFFF
```

### Expansion
Next, the number of rounds is reduced to 64, so we do less expansion but add more complexity

```
def expand(block):
    w = struct.unpack('!16L', block) # Turn block into series of 16 unsigned longs (4 bytes each)
    w += [0] * (80 - len(w)) # We are going to expand this from 16 to 80

    for i in range(16, 64):
        # In each of these we take two numbers i-15 and i-2 and we
        # take different parts of the number and scramble it by 
        # rotating and XORing
        s0 = (rotate(w[i-15], 7)) ^ (rotate(w[i-15], 18)) ^ (w[i-15] >> 3)
        s1 = (rotate(w[i-2], 17)) ^ (rotate(w[i-2], 19)) ^ (w[i-2] >> 10)

        # Added together with i-16 and i-17
        w[i] = (w[i-16] + s0 + w[i-7] + s1) & 0xFFFFFFFF

    return w
```

### Main Loop
There are a few main differences between SHA-2 and SHA-1:
- Instead of each constant being used for a quarter of the rounds, we have a unique constant for each round
- We aren't using different functions for different rounds
- Instead of just rotating the middle value, we are taking the ground value and adding it in

```
# Initialize array of round constants: 
# (first 32-bits of the fractional parts of the cube roots of the first 64 primes 2..311):
k = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
]

def grind(block, init_values):
    w = expand(block)
    a, b, c, d, e, f, g, h = init_values

    for i in range(64):
        s0 = (rotate(a, 2)) ^ (rotate(a, 13)) ^ (rotate(a, 22))
        s1 = (rotate(e, 6)) ^ (rotate(e, 11)) ^ (rotate(e, 25))

        ch = (e & f) ^ ((~e) & g) # Choose Function
        maj = (a & b) ^ (a & c) ^ (b & c) # Majority Function

        # Introduce a single 4byte long
        grind = (h + s1 + ch + k[i] + w[i]) & 0xFFFFFFFF

        # Unlike with previous versions we aren't rotating the middle
        # value but adding the grinded value to it
        d = d + grind & 0xFFFFFFFF

        # As before we added the grinded value but include the 
        # majority function
        new_a = grind + s0 + maj & 0xFFFFFFFF

        # Rotate everything, h falls off the end
        a, b, c, d, e, f, g, h = new_a, a, b, d, e, f, g

    return [a, b, c, d, e, f, g, h]
```

## SHA-3
Since SHA-2 hasn't been broken yet we haven't moved to SHA-3, it uses a completely different mechanism so I didn't have explain it in the original post, but I may add a later update in the future. In the mean time you can check out the [wikipedia page](https://en.wikipedia.org/wiki/SHA-3).