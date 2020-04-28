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
    public GameObject wd;


    public float movementSpeed = 2f;


    private void Start()
    {
        animator = player.GetComponent<Animator>();
    }
    void Update()
    {
        float distance = Vector3.Distance(player.transform.position, transform.position);
        currentAttackState = player.GetComponent<Animator>().GetCurrentAnimatorStateInfo(0).IsName("attack");
        transform.LookAt(player.transform);
        transform.position += transform.forward * movementSpeed * Time.deltaTime;
        Debug.Log("attack " + currentAttackState);
        if (distance > 20)
        {
       
            Destroy(transform.gameObject);

            /*
            float j = 5;
            for (int i = 0; i < 3; i++)
            {
                Instantiate(wd, new Vector3(player.transform.position.x-j, player.transform.position.y, player.transform.position.z-j), Quaternion.identity);
                j += 0.5f;
                transform.Rotate(0, 0, 0);
                if (j==10)
                    j=2;
            }
            */
          
        }
       


    }
    void OnCollisionEnter(Collision collisionInfo)
    {
        currentAttackState = player.GetComponent<Animator>().GetCurrentAnimatorStateInfo(0).IsName("attack");
        animator = player.GetComponent<Animator>();
        
        Debug.Log("attack " + currentAttackState);
        
        if (collisionInfo.gameObject.tag == "arthur" && !currentAttackState)
        {
            SceneManager.LoadScene(0);

        }

        //attacking enemy doesnt work 
        if (collisionInfo.gameObject.tag == "arthur" && currentAttackState)
        {
            Destroy(transform.gameObject);
        }
    }
}