using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.AI;
public class WalkingDeadAI : MonoBehaviour
{
    bool currentAttackState;
    public GameObject player;
    Animator animator;
    

    private static int numbersOfWD;
    public float movementSpeed;


    private void Start()
    {
        numbersOfWD = 10;
        movementSpeed = 2f;
        animator = player.GetComponent<Animator>();
    }
    void Update()
    {
        float distance = Vector3.Distance(player.transform.position, transform.position);
        Debug.Log(numbersOfWD);
      
       
        transform.LookAt(player.transform);
        transform.position += transform.forward * movementSpeed * Time.deltaTime;
       
        if (distance > 20)
        {

            if (numbersOfWD == 1)
            {
                SceneManager.LoadScene(1);
            }
            Destroy(transform.gameObject);
            numbersOfWD--;
        }




    }
 
    void OnCollisionEnter(Collision collisionInfo)
    { 
         animator = player.GetComponent<Animator>();
        
       
        
       
        
        if (collisionInfo.gameObject.tag == "arthur" && !animator.GetBool("attack") )
        {
            SceneManager.LoadScene(0);

        }
        
        //attacking enemy doesnt work 
        if (collisionInfo.gameObject.tag == "arthur"&& animator.GetBool("attack"))
        {
            Destroy(transform.gameObject);
        }
       
    }
}